# This file has procedures for working with Stylus Common UI tools
##################################################
#       enics_start_stage
#       -----------------
#  Starts a new stage in the flow
#    sets the this_run(stage) variable
#    also saves starting time of the stage
##################################################
proc enics_start_stage {stage} {
    global design this_run 

    if {$stage == ""} {
        enics_message "You have to define a stage for using the enics_start_stage procedure"
        return
    } 

    set this_run(stage) $stage
    clear
    enics_message "Starting stage $stage" high

    # Saving and printing the start time for the stage
    set systemTime [clock seconds]
    set formattedTime [clock format $systemTime -format %H:%M]
    set formattedDate [clock format $systemTime -format %d/%m/%Y]
    set stageTime "[clock format $systemTime -format %Y%m%d]_[clock format $systemTime -format %H%M%S]"
    enics_message "Current time is: $formattedDate $formattedTime"
    set this_run(${stage}_start_time) $systemTime

    # Printing run details for the starting stage
    if {$stage == "start"} {
        enics_message "This session is running on Hostname : [info hostname]"
        enics_message "The log file is [get_db / .log_file] and the command file is [get_db / .cmd_file]"
    } elseif {$stage == "floorplan"} {
        gui_set_draw_view fplan
    } elseif {$stage == "placement"} {
        gui_set_draw_view place
        set_db  opt_new_inst_prefix "place_opt_inst_"
        set_db  opt_new_net_prefix  "place_opt_net_"
    } elseif {$stage == "cts"} {
        set_db opt_new_inst_prefix "cts_opt_inst_"
        set_db opt_new_net_prefix  "cts_opt_net_"
    } elseif {$stage == "post_cts_opt"} {
        set_db opt_new_inst_prefix "post_cts_opt_inst_"
        set_db opt_new_net_prefix  "post_cts_opt_net_"
    } elseif {$stage == "route"} {
        set_db opt_new_inst_prefix "route_opt_inst_"
        set_db opt_new_net_prefix  "route_opt_net_"
    } elseif {$stage == "signoff"} {
        set_db opt_new_inst_prefix "signoff_opt_inst_"
        set_db opt_new_net_prefix  "signoff_opt_net_"
    } 
    
    enics_message "--------------------------------------------------" low
} ; # END enics_start_stage


##################################################
#       enics_create_stage_reports
#       --------------------------
#  Creates all the appropriate reports for the
#   current design stage
##################################################
proc enics_create_stage_reports {args} {
    global design this_run

    # Define default values for the options
    array set options " -save_db no \
                        -metrics yes \
                        -help 0"

    set help_string "USAGE: enics_create_stage_reports -save_db yes/no -metrics yes/no -help"

    # Process arguments and override defaults
    while {[llength $args] > 0} {
        set option [lindex $args 0]

        # Handle each option explicitly
        if {[info exists options($option)]} {
            if {$option eq "-help"} {
                set options(-help) 1
            } else {
                set options($option) [lindex $args 1]
                set args [lrange $args 1 end]
            }
        } else {
            puts "Unknown option: $option"
            puts $help_string
            return
        }
        set args [lrange $args 1 end]
    }

    # Display help message if requested
    if {$options(-help)} {
        puts $help_string
        return
    }

    # Main logic starts here
    set stage $this_run(stage)
    enics_message "Starting to create reports for stage: $stage" medium
    set this_run(${stage}_end_time) [clock seconds]
    set rpt_dir $design(reports_dir)/$stage/
    enics_message "Reports directory is: $rpt_dir" low
    set export_dir $design(export_dir)/$stage/
    enics_message "Export directory is: $export_dir" low
    set dbs_dir $design(dbs_dir)/$stage/
    enics_message "Database directory is: $dbs_dir" low
    exec mkdir -pv $rpt_dir
    exec mkdir -pv $export_dir
    exec mkdir -pv $dbs_dir


    if {$options(-save_db) == "yes"} {
        enics_message "Writing out Database"
        write_db $dbs_dir -verilog
    }
    if {$options(-metrics) == "yes"} {
        enics_message "Reporting Metrics"
        create_snapshot -name $stage -categories "design setup hold power"
        report_metric -file $rpt_dir/metrics.html -format html
        enics_message "To view design metrics run:\n chromium-browser $rpt_dir/metrics.html"
    }
    ####################################
    ####   Init_Design Reports     ####
    ####################################
    if {$stage=="init_design"} {
        enics_message "Starting specific reports for post import design"
        check_design -out_file $rpt_dir/check_design.rpt -type "power_intent timing"
        time_design -pre_place -report_dir $rpt_dir/pre_place_setup_timing
        report_timing -unconstrained -max_paths 20 > $rpt_dir/unconstrained_paths.rpt
    }
    ####################################
    ####      Floorplan Reports     ####
    ####################################
    if {$stage=="floorplan"} {
        enics_message "Starting specific reports for floorplan stage"
        check_floorplan -report_density -out_file $rpt_dir/check_floorplan.rpt
        check_well_taps > $rpt_dir/well_taps.rpt
        check_drc -check_only special -out_file $rpt_dir/special_route_drc.rpt
        check_connectivity -type special -ignore_unrouted_nets -out_file $rpt_dir/special_route_connectivity.rpt
        enics_message "Use: delete_drc_markers to remove any DRCs after looking at them" low
    }
    ####################################
    ####  Post Placement Reports    ####
    ####################################
    if {$stage == "placement"} {
        enics_message "Writing out Database at $dbs_dir"
        write_db $dbs_dir -verilog
        enics_message "Starting specific reports for post-placement stage"
        check_place $rpt_dir/check_place.rpt
        report_density_map > $rpt_dir/density_map.rpt
        report_place_density > $rpt_dir/place_density.rpt
        report_congestion -hotspot -overflow > $rpt_dir/congestion.rpt
        check_design -out_file $rpt_dir/check_design.rpt -type "place opt timing power_intent"
        check_drc -ignore_trial_route -out_file $rpt_dir/drc.rpt
        time_design -pre_cts -ideal_clock -num_paths 20 -report_dir $rpt_dir/post_place_setup_timing
        delete_drc_markers
    }
    ####################################
    ####     Post CTS Reports       ####
    ####################################
    if {$stage=="cts" || [string first clock $stage] != -1 } {
        enics_message "Writing out Database at $dbs_dir"
        write_db $dbs_dir -verilog
        enics_message "Starting specific reports for post CTS stage"
        report_clock_tree_convergence -out_file $rpt_dir/clock_tree_convergence.rpt
        report_clock_trees -out_file $rpt_dir/clock_trees.rpt
        check_design -out_file $rpt_dir/check_design.rpt -type "cts timing power_intent"
        if {[llength [get_db skew_groups]] > 0 } {report_skew_groups -summary -out_file $rpt_dir/skew_groups.rpt}
        time_design -post_cts -num_paths 20 -report_dir $rpt_dir/post_cts_setup_timing
        time_design -post_cts -hold -num_paths 20 -report_dir $rpt_dir/post_cts_hold_timing
    }
    if {$stage=="post_cts_opt"} {
        enics_message "Writing out Database at $dbs_dir"
        write_db $dbs_dir -verilog
        enics_message "Starting specific reports after post CTS optimization"
        check_design -out_file $rpt_dir/check_design.rpt -type "cts opt timing power_intent"
        time_design -post_cts -num_paths 20 -report_dir $rpt_dir/post_cts_opt_setup_timing
        time_design -post_cts -hold -num_paths 20 -report_dir $rpt_dir/post_cts_opt_hold_timing
    }
    ####################################
    ####    Post Route Reports      ####
    ####################################
    if {$stage=="route"} {
        enics_message "Writing out Database at $dbs_dir"
        write_db $dbs_dir -verilog
        enics_message "Starting specific reports after routing"
        set_db extract_rc_engine post_route
        set_db extract_rc_effort_level high
        set_db delaycal_enable_si true
        check_design -out_file $rpt_dir/check_design.rpt -type "route timing power_intent"
        time_design -post_route -num_paths 20 -report_dir $rpt_dir/post_route_setup_timing
        time_design -post_route -hold -num_paths 20 -report_dir $rpt_dir/post_route_hold_timing
        check_drc -out_file $rpt_dir/drc.rpt
        check_connectivity -out_file $rpt_dir/connectivity.rpt
        delete_drc_markers
    }
    ####################################
    ####   Post Route Opt Reports   ####
    ####################################
    if {$stage=="post_route_opt"} {
        enics_message "Writing out Database at $dbs_dir"
        write_db $dbs_dir -verilog
        enics_message "Starting specific reports after post-route optimization"
        set_db extract_rc_engine post_route
        set_db extract_rc_effort_level high
        set_db delaycal_enable_si true
        check_design -out_file $rpt_dir/check_design.rpt -type "place cts route opt signoff timing power_intent"
        time_design -post_route -num_paths 20 -report_dir $rpt_dir/post_route_opt_setup_timing
        time_design -post_route -hold -num_paths 20 -report_dir $rpt_dir/post_route_opt_hold_timing
        check_drc -out_file $rpt_dir/drc.rpt
        check_connectivity -out_file $rpt_dir/connectivity.rpt
        delete_drc_markers
    }
    ####################################
    ####    Signoff Reports         ####
    ####################################
    if {$stage=="signoff"} {
        enics_message "Writing out Database at $dbs_dir"
        write_db $dbs_dir -verilog
        enics_message "Starting specific reports for Sign-Off"
        set_db extract_rc_engine post_route
        set_db extract_rc_effort_level signoff
        set_db delaycal_enable_si true
        check_design -out_file $rpt_dir/check_design.rpt -type "place cts route opt signoff timing power_intent"
        #time_design_signoff       -report_dir $rpt_dir/signoff_timing
        time_design -post_route -num_paths 20 -report_dir $rpt_dir/signoff_setup_timing
        time_design -post_route -hold -num_paths 20 -report_dir $rpt_dir/signoff_hold_timing
        check_drc -out_file $rpt_dir/drc.rpt
        check_connectivity -out_file $rpt_dir/connectivity.rpt
        delete_drc_markers
    }
}
##################################################
#       enics_end_stage
#       ---------------
#  This is a command for ending a design stage
##################################################
proc enics_end_stage {} {
    global design this_run
    
    enics_create_stage_reports

    set stage $this_run(stage)
    set stage_time [clock format [expr $this_run(${stage}_end_time) - $this_run(${stage}_start_time)] -format %H:%M]
    enics_message "******  The run time of stage $stage was: $stage_time ******" low
}

##################################################
#       enics_print_debug_data
#       -------------
#  This is a command for printing variable values
#     to a file for easier debugging
##################################################
proc enics_print_debug_data {write_or_append {debug_file "debug.txt"} this_file var_list dic_list} {
    #global design tech tech_files env
    
    set df [open $debug_file $write_or_append]
    puts $df "\n******************************************"
    puts $df "* Values loaded from $this_file *"
    puts $df "******************************************"
    foreach var $var_list {
        global $var
        puts $df "$var = \t[set $var]"
    }

    foreach dic $dic_list {
        global $dic
        foreach key [array names $dic] {
            puts $df "${dic}(${key}) = \t[set ${dic}([set key])]"
        }
    }

    close $df
}

##################################################
#       enics_message
#       -------------
#  This is a command for printing messages to the
#     screen and log file
#  Importance high will print a bold message
#  Importance medium (default) will print an underlined message
#  Importance low will print a one line message
##################################################
proc enics_message {msg {importance medium}} {
    set enics_message "ENICSINFO: $msg"
    set message_length [string length $enics_message]
    
    set  ANSI(red) "\033\[1;31m"
    set  ANSI(green) "\033\[1;32m"
    set  ANSI(cyan) "\033\[1;36m"
    set  ANSI(reset) "\033\[0m"

    if {$importance=="high"} {
        puts "$ANSI(red)"
        puts [string repeat "*" [expr 10+$message_length]]
        puts "**   $enics_message   **" 
        puts [string repeat "*" [expr 10+$message_length]]
        puts "$ANSI(reset)"
    } elseif {$importance=="medium"} {
        puts "$ANSI(green)"
        puts "$enics_message"
        puts [string repeat "-" $message_length]
        puts "$ANSI(reset)"
    } elseif {$importance=="low"} {
        puts "$ANSI(cyan)$enics_message$ANSI(reset)" 
    } else {
        puts "ENICSINFO: WARNING - Incorrect usage of proc enics_message"
        puts "ENICSINFO: Correct usage:enics_message <message> high|medium|low"
    }
}

##################################################
#       enics_reload_scripts
#       --------------------
#  Reloads the defines and procedures
##################################################
proc enics_reload_scripts {} {
    global design env
    # Load general procedures
    source ../scripts/procedures.tcl -quiet
    # Load the specific definitions for this project
    source ../inputs/$design(TOPLEVEL).defines -quiet
}

##################################################
#       enics_enable_sdc_commands
#       -------------------------
#  Lets you write SDC commands in interactive mode
##################################################
proc enics_enable_sdc_commands {} {
    set_interactive_constraint_modes [all_constraint_modes]
}

##################################################
#       enics_reload_sdc
#       ----------------
#  Reloads the SDC Files after modifying them
#    default is for all constraint modes
##################################################
proc enics_reload_sdc {{constraint_mode all}} {
    global design tech runtype
    if {$constraint_mode == "all"} {
        set constraint_mode_list [get_db constraint_modes]
    } else {
        set constraint_mode_list "constraint_mode:$constraint_mode"
    }
    foreach cm $constraint_mode_list {
        update_constraint_mode -name [get_db $cm .name] -sdc_files [get_db $cm .sdc_files]
    }
}



##################################################
#       enics_default_cost_groups
#       -------------------------
#  Defines default cost groups:
#  reg2reg, in2reg, reg2out, in2out
##################################################
proc enics_default_cost_groups {} {
    global runtype design
    if {$runtype == "synthesis"} {
        # Genus uses the "define_cost_group" and "path_group" commands
        # They create a database object called "cost_group"
        # These commands do not exist in Innovus, nor does the db object
        # reg2reg
        define_cost_group -name reg2reg -design $design(TOPLEVEL)
        path_group -from [all_registers] -to [all_registers] -group reg2reg -name reg2reg \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "reg2reg"
        # in2reg
        define_cost_group -name in2reg -design $design(TOPLEVEL)
        path_group -from [all_inputs]  -to [all_registers] -group in2reg -name in2reg \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "in2reg"
        # reg2out
        define_cost_group -name reg2out -design $design(TOPLEVEL)
        path_group -from [all_registers] -to [all_outputs] -group reg2out -name reg2out \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "reg2out"
        # in2out
        define_cost_group -name in2out -design $design(TOPLEVEL)
        path_group -from [all_inputs]  -to [all_outputs] -group in2out -name in2out \
            -view $design(selected_setup_analysis_views)
        lappend design(cost_groups) "in2out"  
    } elseif {$runtype == "pnr" } {
        # Innovus does not have the "define_cost_group" or "path_group" commands
        # Instead, it uses the command "group_path" (...very confusing)
        # This does not create a database object, like in genus, so to get a list
        #   of Path Groups, use get_path_groups or report_path_groups
        # create_basic_path_groups automatically creates reg2reg, in2reg, etc.
        create_basic_path_groups -expanded 
        foreach_in_collection pg [get_path_groups] { lappend design(cost_groups) [get_db $pg .name] }
    } 
}

##################################################
#       enics_export_design
#       -------------------
#      Exports the required files
##################################################
proc enics_export_design {args} {
    global design this_run

    # Define default values for the options
    array set options " -uniquify no \
                        -lef no \
                        -gds no \
                        -lvs_netlist no \
                        -netlist yes \
                        -def no \
                        -spef no \
                        -sdf yes \
                        -ilm no \
                        -libs no \
                        -help 0"

    set help_string "USAGE: enics_export_design -uniquify yes/no -gds yes/no \n \
                    \t\t-lvs_netlist yes/no -netlist yes/no -def yes/no -spef yes/no \
                    \t\t-sdf yes/no -ilm yes/no -libs yes/no -help"

    # Process arguments and override defaults
    while {[llength $args] > 0} {
        set option [lindex $args 0]

        # Handle each option explicitly
        if {[info exists options($option)]} {
            if {$option eq "-help"} {
                set options(-help) 1
            } else {
                set options($option) [lindex $args 1]
                set args [lrange $args 1 end]
            }
        } else {
            puts "Unknown option: $option"
            puts $help_string
            return
        }
        set args [lrange $args 1 end]
    }

    # Display help message if requested
    if {$options(-help)} {
        puts $help_string
        return
    }

    # Main logic starts here
    enics_message "Starting to create export files" medium
    set export_dir $design(export_dir)/$this_run(stage)/
    enics_message "Export directory is: $export_dir" low
    exec mkdir -pv $export_dir


    if {$options(-uniquify) == "yes"} {
        enics_message "Adding suffix to modules for integration into Top Level"
        update_names -module -suffix $design(TOPLEVEL)
    }
    if {$options(-lef) == "yes"} {
        enics_message "Creating LEF abstract of block"
        write_lef_abstract $export_dir/$design(TOPLEVEL).lef \
                -pg_pin_layers {1 6} -top_layer 6 -stripe_pins
    }
    if {$options(-gds) == "yes"} {
        enics_message "Streaming out GDS"
        set_db write_stream_text_size 0.02;
        write_stream $export_dir.gds.gz -merge $tech(ALL_GDS) \
            -mode NOFILL -map_file $tech(GDS_LAYER_MAP) -unit 1000;
    }
    if {$options(-lvs_netlist) == "yes"} {
        enics_message "Exporting netlist for LVS"
        write_netlist $export_dir/$design(TOPLEVEL)_lvs.v -exclude_leaf_cells -phys \
            -flatten_bus ; #-exclude_insts_of_cells <physical cells>
    }
    if {$options(-netlist) == "yes"} {
        enics_message "Exporting netlist for GLS"
        write_netlist $export_dir/$design(TOPLEVEL).v -exclude_leaf_cells
    }
    if {$options(-def) == "yes"} {
        enics_message "Exporting DEF"
        set_db write_def_include_lef_ndr  1
        set_db write_def_include_lef_vias 1
        set_db write_def_lef_out_version  5.8
        write_def -routing -floorplan -netlist $export_dir/$design(TOPLEVEL).5p8.def.gz -used_via
    }
    if {$options(-spef) == "yes"} {
        enics_message "Exporting SPEF"
        foreach corner [get_db [get_db rc_corners] .name] {
            write_parasitics -spef $export_dir/$design(TOPLEVEL)_${corner}.spef.gz -rc_corner $corner
        }
    }
    if {$options(-sdf) == "yes"} {
        enics_message "Exporting SDF"
        write_sdf $export_dir/$design(TOPLEVEL).sdf \
            -recompute_delaycal -precision 4 -delimiter . -target_application verilog
    }
    if {$options(-ilm) == "yes"} {
        enics_message "Writing out ILM"
        write_ilm -model_type all -to_dir $export_dir/ilm
    }
    if {$options(-libs) == "yes"} {
        enics_message "Creating .libs of block"
        set analysis_views_list [get_db designs .analysis_views.name]
        exec mkdir -pv $export_dir/libs
        foreach view [get_db designs .analysis_views.name] {
            write_timing_model -cell_name [get_db designs .name] $export_dir/libs/${view}.lib -view ${view} -include_power
        }        
    }
}

##################################################
#       enics_report_timing
#       -------------------
#  Reports timing and saves it in the appropriate directory
##################################################
proc enics_report_timing {{reports_path "../reports/"} } {
    global design this_run
    mkdir -pv ${reports_path}/$this_run(stage)/
    set_db timing_report_fields \
        "timing_point flags arc edge cell fanout transition delay arrival"
    #set timing_report_enable_auto_column_width  true
    #set_table_style -nosplit -no_frame_fix_width    report_timing 
    foreach cg $design(cost_groups) {
        report_timing -group [get_db cost_groups -match $cg] \
            > "${reports_path}/$this_run(stage)/${cg}.timing.rpt"
    }
}


    

##################################################
#       enics_restore_design
#       --------------------------
#  Creates all the appropriate reports for the
#   current design stage
##################################################
proc enics_restore_design {db_path design_name {args ""} } {
    global design paths tech tech_files debug_file env
    global TECHNOLOGY SC_TECHNOLOGY SRAM_TECHNOLOGY IO_TECHNOLOGY METAL_STACK TRACKS IO_METAL_STACK

    array set options {-tool innovus -help 0}

    set help_string "USAGE: enics_restore_design <db_path> <design_name> -tool innovus/genus -help"


    while {[llength $args]} {
        switch -glob -- [lindex $args 0] {
            -tool*     {set args [lassign $args - options(-tool)]}
            -help      {set options(-help) 1 ; set args [lrange $args 1 end]}           
            default break
        }
    }
    if {$options(-help)} {
        puts $help_string
    } else {
        enics_message "Loading $design_name saved at: $db_path "
        set design(TOPLEVEL) $design_name
        set debug_file "debug.txt"
        if {$options(-tool) == "genus"} {
            set runtype "synthesis"
            source ../inputs/$design(TOPLEVEL).defines -quiet
            source ../libraries/libraries.$TECHNOLOGY.tcl -quiet
            source ../libraries/libraries.$SC_TECHNOLOGY.tcl -quiet
            source ../libraries/libraries.$SRAM_TECHNOLOGY.tcl -quiet
            if {$design(FULLCHIP_OR_MACRO)=="FULLCHIP"} {
                source ../libraries/libraries.$IO_TECHNOLOGY.tcl -quiet
                read_db $db_path
            }
        }
        if {$options(-tool) == "innovus"} {
            set runtype "pnr"
            source ../inputs/$design(TOPLEVEL).defines -quiet
            source ../libraries/libraries.$TECHNOLOGY.tcl -quiet
            source ../libraries/libraries.$SC_TECHNOLOGY.tcl -quiet
            source ../libraries/libraries.$SRAM_TECHNOLOGY.tcl -quiet
            if {$design(FULLCHIP_OR_MACRO)=="FULLCHIP"} {
                source ../libraries/libraries.$IO_TECHNOLOGY.tcl -quiet
                read_db $db_path
            }
        }
    }
}


proc enics_get_num_of_cpus_enabled { fh } {
    if [catch {open $fh r} fileId] {
        puts stderr "Cannot open $fh: $fileId"
    } else {
        foreach line [split [read $fileId] \n] {
            if {[string match "*Total CPU*" $line]} {
                set cpusEnabled [string trim [lindex [split $line ":"] 1]]
            }
        }
        close $fileId
    }
    return $cpusEnabled
}

proc enics_round_to_grid {grid point {round_dir "up"} {debug 0}} {
    # grid      : resolution to align to
    # point     : coordinate to align
    # round_dir : rounding direction
    if {$round_dir eq "up"} {
        set num_of_inst [expr int(ceil($point/$grid))]
        set result [expr $num_of_inst*$grid]
        set fix    [expr $result - $point]
        set shift [join [list "Shift: " "+" $fix] ""]
    } elseif {$round_dir eq "down"} {
        set num_of_inst [expr int(floor($point/$grid))]
        set result [expr $num_of_inst*$grid]
        set fix    [expr $point - $result]
        set shift [join [list "Shift: " "-" $fix] ""]
    } else {
        puts "Error! Use up or down round direction."
        return 0
    }

    if $debug {
        puts "Round-${round_dir} of $point value to $grid resolution --> $shift --> $result (with $num_of_inst instances)"
    }
    return $result
}

proc enics_grow_box {ibox grow_hor_L grow_hor_R grow_ver_T grow_ver_B {debug 0}} {
    ####################################################################
    ## Expand any rectangular box = llx,lly,utx,ury in all directions ##
    ####################################################################

    set ibox_t [flat_hier_lst $ibox]
    set obox [list \
                  [expr [lindex $ibox_t 0] - [expr $grow_hor_L]] \
                  [expr [lindex $ibox_t 1] - [expr $grow_ver_B]] \
                  [expr [lindex $ibox_t 2] + [expr $grow_hor_R]] \
                  [expr [lindex $ibox_t 3] + [expr $grow_ver_T]]
             ]
    if {$debug} {
        puts "llx : [lindex $ibox_t 0] - [expr $grow_hor_L] --> [expr [lindex $obox 0]]"
        puts "lly : [lindex $ibox_t 1] - [expr $grow_ver_B] --> [expr [lindex $obox 1]]"
        puts "urx : [lindex $ibox_t 2] + [expr $grow_hor_R] --> [expr [lindex $obox 2]]"
        puts "ury : [lindex $ibox_t 3] + [expr $grow_ver_T] --> [expr [lindex $obox 3]]"
    }

    return $obox
}

proc enics_grow_polygon_vh {poly grow_v grow_h} {
    ############################################
    ## Expand any polygon in V & H directions ##
    ############################################

    set rects_lst {}

    foreach rect [get_computed_shapes $poly] {
        lappend rects_lst [grow_box $rect $grow_v $grow_v $grow_h $grow_h]
    }

    set rect_accum [lindex $rects_lst 0]
    foreach rect [lrange $rects_lst 1 end] {
        set rect_accum [get_computed_shapes $rect_accum OR $rect]
    }

    return [get_computed_shapes -output polygon $rect_accum]
}

proc enics_flat_hier_lst {data} {
    ###############################################
    ## Flattens any hierarchical list to be flat ##
    ###############################################
    while { $data != [set data [join $data]] } { }
    return $data
}


proc enics_lzip {l1 l2} {
    set res {}
    foreach x $l1 y $l2 {
        if { $x != "" } { lappend res $x }
        if { $y != "" } { lappend res $y }
    }
    return $res
}

proc enics_listcomp {a b} {
    set diff {}
    foreach i $a {
        if {[lsearch -exact $b $i]!=-1} {
            lappend diff $i
        }
    }
    return $diff
}

proc enics_listcomp_diff {a b} {
    set diff {}
    foreach i $a {
        if {[lsearch -exact $b $i]==-1} {
            lappend diff $i
        }
    }
    return $diff
}

proc enics_Rand { {min 0} {max 100} } {
    expr {int(rand() * 100) % ($max + 1 - $min) + $min}
}

proc enics_lcm_lst {lst {UPSCALE 1000}} {
    # UPSCALE used to prevent floating numbers for % TCL operator
    set lcm [lindex $lst 0]; # 1st item as starting value
    foreach i [lrange $lst 1 end] { # Skip 1st item
        set lcm [lcm $lcm $i $UPSCALE]
    }
    return $lcm
}

proc enics_lcm {p q {UPSCALE 1000}} {
    # UPSCALE used to prevent floating numbers for % TCL operator
    set m [expr {$p * $q}]
    if {!$m} {return 0}
    return [expr ($UPSCALE * $m) / [gcd $p $q $UPSCALE]]
}

proc enics_gcd {num1 num2 {UPSCALE 1000}} {
    # UPSCALE used to prevent floating numbers for % TCL operator
    set N1 [expr int([expr $UPSCALE * $num1])]
    set N2 [expr int([expr $UPSCALE * $num2])]
    while {[set tmp [expr {$N1%$N2}]]} {
        set N1 $N2
        set N2 [expr $tmp]
    }
    return $N2
}

proc enics_ladd {l} {                 # Sum all list's items
    set total 0.0
    foreach nxt $l {
        set total [expr {$total + $nxt}]
    }
    return $total
}

proc enics_linc {l d} {                 # Increment all list's items by d
    return [lmap i $l { expr {$i + $d} }]
}

proc enics_lfact {l f} {                # Factorize all list's items by f
    return [lmap i $l { expr {$i * $f} }]
}

proc enics_rmv_lst_b_from_a {la lb} {
    foreach elem $la {dict set y $elem 1}
    foreach elem $lb {dict unset y $elem}
    return [dict keys $y]
}


proc enics_intersect_lsta_lstb { la lb } {
    set result {}
    foreach el $lb {
        if { [lsearch -exact $la $el] != -1 } {
            lappend result $el
        }
    }
    return $result
}

proc enics_lst_prefix { lst str {suffix_char _}} {
    return [lmap x $lst { string cat ${str}${suffix_char} $x }]
}

proc enics_lst_suffix { lst str {suffix_char _}} {
    return [lmap x $lst { string cat ${x}${suffix_char} $str }]
}

proc enics_range {from to {step 1}} {
    set res $from
    while {$step>0?$to>$from:$to<$from} {lappend res [incr from $step]}
    return $res
}

proc enics_list_from_file {filename} {
    set f [open $filename r]
    set data [split [string trim [read $f]]]
    close $f
    return $data
}

proc enics_wrap_macro_with_plc_corner_halos {rect {corn_skip_lst "0 0 0 0"} {corn_size_lst "4 4 4 4"}} {
    set rect [flat_hier_lst $rect]
    for {set i 0} {$i < 4} {incr i} {
        set radius [expr {[lindex $corn_size_lst $i]/2}]
        if { [expr !{[lindex $corn_skip_lst $i]}] } {
            switch $i {
                0 {
                    set corner_llx [expr [lindex $rect 0] - $radius]
                    set corner_lly [expr [lindex $rect 1] - $radius]
                    set corner_urx [expr [lindex $rect 0] + $radius]
                    set corner_ury [expr [lindex $rect 1] + $radius]
                }
                1 {
                    set corner_llx [expr [lindex $rect 0] - $radius]
                    set corner_lly [expr [lindex $rect 3] - $radius]
                    set corner_urx [expr [lindex $rect 0] + $radius]
                    set corner_ury [expr [lindex $rect 3] + $radius]
                }
                2 {
                    set corner_llx [expr [lindex $rect 2] - $radius]
                    set corner_lly [expr [lindex $rect 3] - $radius]
                    set corner_urx [expr [lindex $rect 2] + $radius]
                    set corner_ury [expr [lindex $rect 3] + $radius]
                }
                3 {
                    set corner_llx [expr [lindex $rect 2] - $radius]
                    set corner_lly [expr [lindex $rect 1] - $radius]
                    set corner_urx [expr [lindex $rect 2] + $radius]
                    set corner_ury [expr [lindex $rect 1] + $radius]
                }
            }
            set corner_box "$corner_llx $corner_lly $corner_urx $corner_ury"
            create_place_blockage -name macro_corner_plc_blk -rects $corner_box -snap_to_site
        }
    }
}


proc enics_add_clk_decap_near_bufs { decap_cell itr } {

    if { [get_db base_cells $decap_cell] == "" } {
        puts "\n\n*** Error : Cell $decap_cell does not exist in Library ***\n\n"
        return
    }

    ### Fix registers and clock instances ###
    foreach clk_cell [get_db clock_trees .insts -if !.is_inside_ilm -unique] {
        set_db $clk_cell .place_status fixed
    }
    set clk_sink_pins_dpos [get_db clock_trees .sinks -if {.obj_type == pin}]
    foreach clk_sink [get_db $clk_sink_pins_dpos .inst -if !.is_inside_ilm -unique] {
        set_db $clk_cell .place_status fixed
    }

    set ctr 0; # Number of created & placed decaps

    # Foreach clock tree cell insert a decap cell on top of it (legalization occurs later):
    foreach clkbuf [get_db insts -if {!.is_inside_ilm && .cts_node_type != ""}] {

        set clkbuf_bbox   [get_db $clkbuf .bbox]
        set clkbuf_orient [get_db $clkbuf .orient]
        set clkbuf_loc    [get_db $clkbuf .location]
        set clkbuf_name   [get_db $clkbuf .name]
        if { [get_db insts ${clkbuf}_CLK_DECAP_BUF_ITR${itr}] == "" } {
            puts ">>> $ctr : Adding DeCap cell $decap_cell near $clkbuf @ ${clkbuf_bbox} ..."
            incr ctr
            create_inst -physical -base_cell $decap_cell -name ${clkbuf_name}_CLK_DECAP_BUF_ITR${itr} -location $clkbuf_loc
        }
    }
}

# foreach clkbuf [get_db insts -if {.is_inside_ilm == false && (.cts_node_type == buffer || .cts_node_type == inverter || .cts_node_type == clock_gate || .cts_node_type == logic || .cts_node_type == source)}] {

proc enics_add_clk_decap_near_regs { decap_cell itr } {

    if { [get_db base_cells $decap_cell] == "" } {
        puts "\n\n*** Error : Cell $decap_cell does not exist in Library ***\n\n"
        return
}

    ### Fix registers and clock instances ###
    foreach clk_cell [get_db clock_trees .insts -if !.is_inside_ilm -unique] {
        set_db $clk_cell .place_status fixed
    }
    set clk_sink_pins_dpos [get_db clock_trees .sinks -if {.obj_type == pin}]
    foreach clk_sink [get_db $clk_sink_pins_dpos .inst -if !.is_inside_ilm -unique] {
        set_db $clk_cell .place_status fixed
    }

    set ctr 0;                    # Number of created & placed decaps
    # Foreach clock tree sink insert a decap cell on top of it (legalization occurs later):
    foreach cts_sink [get_db $clk_sink_pins_dpos .inst -if {!.is_inside_ilm && .base_cell.is_flop} -unique] {

        set cts_sink_bbox   [get_db $cts_sink .bbox]
        set cts_sink_orient [get_db $cts_sink .orient]
        set cts_sink_loc    [get_db $cts_sink .location]
        set cts_sink_name   [get_db $cts_sink .name]
        if { [get_db insts ${cts_sink}_CLK_DECAP_REG_ITR${itr}] == "" } {
            puts ">>> $ctr : Adding DeCap cell $decap_cell near $cts_sink @ ${cts_sink_bbox} ..."
            incr ctr
            create_inst -physical -base_cell $decap_cell -name ${cts_sink_name}_CLK_DECAP_REG_ITR${itr} -location $cts_sink_loc
        }
    }
}

proc enics_legalize_decap_dpos_placement { decap_dpos type itr } {

    set_db eco_refine_place       false
    set_db eco_update_timing      false
    set_db eco_honor_fixed_status true

    set non_ilm_decap_dpos [get_db $decap_dpos -if "!.is_inside_ilm && .base_name == *CLK_DECAP_${type}_ITR${itr}"]
    set_db $non_ilm_decap_dpos .place_status placed
    place_detail -inst [get_db $non_ilm_decap_dpos .name]; # Legalization
    set_db $non_ilm_decap_dpos .place_status soft_fixed

    reset_db eco_refine_place
    reset_db eco_update_timing
    reset_db eco_honor_fixed_status

    check_place -ignore_out_of_core

    set plc_violated_decap_dpos [get_db [get_db markers -if {.type == place}] .objects *DECAP_${type}_ITR${itr}*]
    foreach dpo [get_db $plc_violated_decap_dpos -if !.is_inside_ilm] {
        if { $dpo != "" } {delete_inst -inst [get_db $dpo .name]}
    }

    check_place -ignore_out_of_core
}

proc enics_add_decap_around_mem_dpo { decap_cell mem_dpo } {

    if { [get_db base_cells $decap_cell] == "" } {
        puts "\n\n*** Error : Cell $decap_cell does not exist in Library ***\n\n"
        return
    }

    set_db eco_refine_place       false
    set_db eco_update_timing      false
    set_db eco_honor_fixed_status true

    set mem_box  [get_db $mem_dpo .place_halo_bbox]
    set mem_name [get_db $mem_dpo .name]

    set ctr 0;                    # Number of created & placed decaps
    foreach ec [get_obj_in_area -obj_type inst -areas $mem_box -abut_only] { # Go over endcaps
        puts ">>> $ctr : Adding DeCap cell $decap_cell around $mem_dpo, near $ec @ [get_db $ec .bbox] ..."
        create_inst -base_cell $decap_cell -name ${mem_name}_CLK_DECAP_MEM_${ctr} \
            -location [get_db $ec .location] -physical
        incr ctr
    }

    set non_ilm_clk_mem_decap_dpos [get_db insts *_CLK_DECAP_MEM_* -if !.is_inside_ilm -unique]
    set_db $non_ilm_clk_mem_decap_dpos .place_status placed
    if { $ctr != 0 } { place_detail -inst [get_db $non_ilm_clk_mem_decap_dpos .name] }; # Legalization
    set_db $non_ilm_clk_mem_decap_dpos .place_status soft_fixed

    reset_db eco_refine_place
    reset_db eco_update_timing
    reset_db eco_honor_fixed_status

    check_place
}

proc enics_net_length {net_name} {
    set length 0
    foreach wire_dpo [get_db [get_db nets $net_name] .wires] {
        set length [expr $length + [get_db $wire_dpo .length]]
    }
    return $length
}

proc enics_get_lst_from_src_lst_by_regex_ptrn {src_lst {regex {}} {invert 0}} {
    if {$invert == 0} {
        return [lsearch -all -inline -regexp $src_lst $regex]
    } else {return [lsearch -all -inline -not -regexp $src_lst $regex]}
}


proc enics_pdict { d {i 0} {p "  "} {s " -> "} } {
    # Nice print of dictionaries for debugging:
    # d - dictionary argument
    # i - indent level
    # p - Nested dictionary entry prefix
    # s - key vs. value separator
    set fRepExist [expr {0 < [llength [info commands tcl::unsupported::representation]]}]
    if { (![string is list $d] || [llength $d] == 1) && [uplevel 1 [list info exists $d]] } {
        set dictName $d
        unset d
        upvar 1 $dictName d
        puts "dict $dictName"
    }
    if { ! [string is list $d] || [llength $d] % 2 != 0 } {
        return -code error  "error: pdict - argument is not a dict"
    }
    set prefix [string repeat $p $i]
    set max 0
    foreach key [dict keys $d] {
        if { [string length $key] > $max } {set max [string length $key]}
    }
    dict for {key val} ${d} {
        puts -nonewline "${prefix}[format "%-${max}s" $key]$s"
        if { $fRepExist && [string match "value is a dict*" [tcl::unsupported::representation $val]] || !$fRepExist && [string is list $val] && [llength $val] % 2 == 0 } {
            puts ""
            pdict $val [expr {$i+1}] $p $s
        } else {puts "'${val}'"}
    }
    return
}

#####################
## GUI procedures: ##
#####################
proc enics_highlight_netlist_neighbors {inst_dpos} {
    set inputs  [get_db $inst_dpos .pins -if {.direction == in}]
    set outputs [get_db $inst_dpos .pins -if {.direction == out}]
    gui_highlight [get_db $inputs  .net.drivers.inst -unique] -color red
    gui_highlight [get_db $outputs .net.loads.inst -unique] -color lime
    gui_highlight $inst_dpos -color cyan; # Highlight the required instances and overwrite any previous highlights
}


##################################################
#       SDC Debugging functions
###################################################

proc enics_get_multi_clock_flops {} {
    ###################################################
    ## Identify and trace the clocks to its source   ##
    ###################################################
    set flops {}
    foreach inst [get_db insts -if .is_sequential] {
        set flop_pins [get_db $inst .pins -if {.direction==in}]
        foreach pin $flop_pins {
            if {[llength [get_db $pin .propagated_clocks]] > 1} {
                lappend flops [vname $inst]
            }
        }
    }
    puts "Flops with multiple clocks: {$flops}"
}

proc enics_get_multi_clock_flops_with_clocks {} {
    #####################################################################
    ## Find the name of the multiple clocks propagated to the clock    ##
    ## pin of flops                                                    ##
    #####################################################################
    foreach inst [get_db insts -if .is_sequential] {
        set flop_pins [get_db $inst .pins -if {.direction==in}]
        foreach pin $flop_pins {
            if {[llength [get_db $pin .propagated_clocks]] > 1} {
                puts "\n\Instance: $inst"
                puts "Pin: $pin"
                foreach clock_info [get_db $pin .propagated_clocks] {
                    array set info_array $clock_info
                    puts "clock: $info_array(clock)"
                }
            }
        }
    }
}

proc enics_check_clock {} {
    #####################################################################
    ## Identify all clock ports that are missing the clock definition  ##
    #####################################################################
    foreach clkp [get_clock_ports] {
        set inv_src [get_db $clkp .clock_sources_inverted]
        set noninv_src [get_db $clkp .clock_sources_non_inverted]
        if {$inv_src=="" & $noninv_src==""} {
            puts "Clock port without clock defined = $clkp"
        }
    }
}


###################################################
#           DRC & Connectivity functions
###################################################
#--------------------------------------#
# The following will delete all the "dangling" wires (you first have to evaluate if you
# are not deleting anything "useful")
proc enics_trim_dangling_wires {} {
    #####################################################################
    ##   The following will delete all the "dangling" wires            ##
    #####################################################################
    check_connectivity -type all -net [get_db [get_db nets -if { .is_physical_only == 1 }] .name] -out_file [get_db current_design .name].conn_CUI.rpt
    set rpt [get_db current_design .name].conn_CUI.rpt
    puts "reading check_connectivity report $rpt . . . "

    if {[catch {open $rpt "r"} fid]} {
        error "Failed to open file $rpt for read."
    } else {
        set allnets {}
        while { [gets $fid line] >= 0 } {
            if {[expr [regexp {^Net\s} $line] && ([regexp {:\s+dangling Wire\s} $line])]} {
                regexp {^Net\s+(\S+):} $line match net
                lappend allnets $net
            }
        }
        close $fid
    # sort list of nets to find unique net names
        set nets [lsort -unique $allnets]
        puts "  Found [llength $nets] unique nets from [llength $allnets] nets reported."
        puts " $nets "
        # trim/delete violations
        puts  " Trimming nets : $nets "

    edit_trim_routes -nets $nets

    #        if {[expr [regexp {^Net\s} $line] && ([regexp {:\s+special open\s} $line] || [regexp {:\s+dangling Wire\s} $line])]}
    # delete_drc_markers
    }
}


proc enics_trim_stripes_dangling_wires {} {
    #####################################################################
    ##   The following will delete ONLY the "dangling" wires           ##
    ##   presented in the design after doing a "connectivity_check"    ##
    ##   (It will not trim each NET, only the stripes with violation)  ##
    #####################################################################
    get_db current_design .markers -if {.subtype == ConnectivityAntenna} -foreach {
        set box [get_db $object .bbox]
        select_obj [get_obj_in_area -area $box -obj_type special_wire]
        edit_trim_routes -selected
    }
}
