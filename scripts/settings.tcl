##########################
# General Genus Settings
##########################
set_db source_verbose true ; # Sourcing files will be reported as verbose

# Attributes that only Genus understands...
if {$runtype=="synthesis"} {
    set_db information_level 9 ; # The log file will report everything
    # set_db hdl_track_filename_row_col true -quiet; # helps with debug but affects runtime
    set_db hdl_language v2001 -quiet
    set_db lp_insert_clock_gating true 
    set_db detailed_sdc_messages true ; # helps read_sdc debug
}

##########################
# General Innovus Settings
##########################
if {$runtype=="pnr"} {
    ###########################
    #       GUI Settings      #
    ###########################
    set_preference AutoRedraw                   1; # Auto Redraw after Layer Change
    set_preference ShowUnplacedInst             1; # Show unplaced instances for sanity inspection
    set_preference MinFPModuleSize              1; # Set the display threshold to minimum
    set_preference LevelFlight                  2;
    set_layer_preference stdRow -is_visible     0; # Don't show standard cell rows by default
    set_layer_preference obsoverlap -is_visible 0; # Hide annoying useless layer on rectilinear macros
    set_preference InstanceText InstanceMaster   ; # Show base_cell name on top of the instance

    set_db write_db_auto_save_user_globals    true


    ###########################
    # TIMING, EXTRACTION, ETC #
    ###########################
    
    # Set on-chip variation analysis
    set_db timing_analysis_type ocv
    set_db timing_analysis_cppr both
    set_db timing_analysis_cppr both
    
    # From Negev - check
    set_db write_db_auto_save_user_globals true
    set_db timing_report_unconstrained_paths true
    set_db timing_cppr_threshold_ps 5
    # Ports without input delay are unconstrained by default
    set_db timing_apply_default_primary_input_assertion false
    set_db timing_enable_si_cppr                        true
    set_db timing_disable_inferred_clock_gating_checks  true
    set_db timing_report_enable_auto_column_width true
    set_table_style -nosplit -no_frame_fix_width
    set_db timing_report_fields {timing_point cell arc flags edge fanout load wire_load pin_load transition annotation delay arrival}

    # DELAYCAL
    # Default false; switch on in routing
    set_db delaycal_enable_si false
    set_db delaycal_equivalent_waveform_model propagation
 
    # SI
    set_db si_delay_separate_on_data true ; # To see incr delay separately in reports
    set_db si_glitch_enable_report true   ; # For correlation to Tempus


    ######################
    #    FLOORPLANNNG    #
    ######################
    set_db floorplan_default_blockage_name_prefix "BLOCKAGE"
    set_db add_rings_detailed_log   true; # More information when creating rings
    set_db add_stripes_detailed_log true; # More information when creating stripes

    # ENDCAPS
    set_db add_endcaps_boundary_tap true
    set_db add_endcaps_prefix "ENDCAP"
    set_db add_endcaps_right_edge $tech(ENDCAPS_right)
    set_db add_endcaps_left_edge  $tech(ENDCAPS_left)

    # WELLTAPS
    set_db add_well_taps_cell  $tech(WELLTAP)
    set_db add_well_taps_rule  $tech(WELLTAP_RULE)
    #set_db add_well_taps_prefix "WELLTAP"
    set design(well_tap_prefix) "WELLTAP"

    ######################
    #    PLACEMENT       #
    ######################
    # PLACE GLOBAL
    set_db place_global_cong_effort auto
    #set_db place_global_place_io_pins false
    
    # PLACE DETAIL
    #set_db place_detail_no_filler_without_implant true
    #set_db place_detail_use_no_diffusion_one_site_filler true

    # TIECELLS
    set_db add_tieoffs_prefix "TIE"
    set_db add_tieoffs_cells "$tech(TIEHI) $tech(TIELO)"
    set_db add_tieoffs_max_fanout   $tech(TIE_MAX_FANOUT)
    set_db add_tieoffs_max_distance $tech(TIE_MAX_DISTANCE)
    
    ######################
    #   OPTIMIZATION     #
    ######################
    # OPT DESIGN
    set_db opt_time_design_compress_reports FALSE
    set_db opt_time_design_expanded_view TRUE
    set_db opt_time_design_num_paths 10
    set_db opt_time_design_report_net FALSE
    set_db opt_honor_fences       true
    set_db opt_fix_hold_verbose   true
    set_db opt_verbose TRUE
    set_db opt_fix_fanout_load true; # Force optimization to correct max_fnaout violations.
    set_db opt_new_inst_prefix "OPT_new_inst"
    set_db opt_new_net_prefix "OPT_new_net"

    ######################
    #      CTS           #
    ######################
    set_db cts_inst_name_prefix "CTS_inst"
    set_db cts_net_name_prefix "CTS_net"

    # Clock Routing Rules
    set tech(layer_names) [lrange [get_db layers .name] 0 9]
    set tech(min_spacing_x) [lindex [get_db layers .min_spacing] 0]
    set tech(min_width_x) [lindex [get_db layers .min_width] 0]
    set tech(min_spacing_y) [lindex [get_db layers .min_spacing] 1]
    set tech(min_width_y) [lindex [get_db layers .min_width] 1]
    set tech(min_spacing_z) [lindex [get_db layers .min_spacing] 7]
    set tech(min_width_z) [lindex [get_db layers .min_width] 7]     
    
    create_route_rule -name 2w2s -width_multiplier {M1:M9 2} -spacing_multiplier {M1:M9 2}
      
    create_route_type -name leaf -route_rule 2w2s \
        -top_preferred_layer    $tech(cts_top_routing_layer_leaf) \
        -bottom_preferred_layer $tech(cts_bottom_routing_layer_leaf)
    set_db cts_route_type_leaf leaf

    create_route_type -name trunk -route_rule 2w2s \
        -top_preferred_layer    $tech(cts_top_routing_layer_trunk) \
        -bottom_preferred_layer $tech(cts_bottom_routing_layer_trunk)
    set_db cts_route_type_trunk trunk

    create_route_type -name top -route_rule 2w2s \
        -top_preferred_layer    $tech(cts_top_routing_layer_top) \
        -bottom_preferred_layer $tech(cts_bottom_routing_layer_top) 
    set_db cts_route_type_top top
    
    
    # set_db cts_target_max_transition_time_top   $clk_slew
    # set_db cts_target_max_transition_time_trunk $clk_slew
    # set_db cts_target_max_transition_time_leaf  $clk_slew    
    
    ######################
    #    ROUTING         #
    ######################
    set_db route_design_antenna_diode_insertion true
    set_db route_design_antenna_cell_name $tech(ANTENNA_DIODE)
    set_db route_design_add_antenna_inst_prefix "ANTENNA"
    set_db route_design_strict_honor_route_rule false; # Do not honor NDR for better DRC fix rate
    set_db route_design_with_via_in_pin true; # Defined in ARM SC user scripts
    set_db route_design_detail_use_multi_cut_via_effort high; # Increase routability
    
    ######################
    #    TIMING          #
    ######################
    set_db delaycal_enable_si true
    set_db delaycal_equivalent_waveform_model propagation

    set_db extract_rc_engine post_route
    set_db extract_rc_effort_level medium
    set_db extract_rc_coupled true
    
    set_db reorder_scan_allow_swapping true ; #Allow swapping between chaines of the same partition

    set_db timing_analysis_cppr               both
    set_db timing_analysis_type               ocv
    # set_db timing_analysis_aocv               true
    # set_db timing_enable_aocv_slack_based     true
    # set_db timing_aocv_analysis_mode          launch_capture; #{launch_capture | clock_only | separate_data_clock | combine_launch_capture}
    # set_db timing_extract_model_aocv_mode     graph_based
    # set_db timing_aocv_derate_mode            aocv_additive;  #{aocv_multiplicative | aocv_additive}

    set_db si_glitch_enable_report            true; # For correlation to Tempus
    set_db timing_report_unconstrained_paths  true

    ######################
    #    SIGNOFF         #
    ######################
    # FILLERS 
    set_db add_fillers_prefix FILLDECAP
    set_db add_fillers_cells [concat $tech(DECAP) $tech(FILLERS)]
    set_db add_fillers_check_drc true
    set_db add_fillers_keep_fixed   true

}

##########################
# General Voltus Settings
##########################
if {$runtype=="power"} {
}




