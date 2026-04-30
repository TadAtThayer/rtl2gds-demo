####################################################
#     DEFINE THE NAME OF THE TOPLEVEL DESIGN       #
#       and variables specific to this run         #
####################################################
set design(TOPLEVEL) "bcd_digit"


# Variables
set runtype "synthesis"
set phys_synth_type "lef" ;  # "lef"    - only read lef and qrctech files
                             # "floorplan"    - read in a def of the floorplan

#############################################
#       Load basic settings
#############################################

# Load general procedures
source ../scripts/procedures.tcl -quiet

enics_start_stage "start"

set debug_file "debug.txt"

# Load the specific definitions for this project
source ../inputs/$design(TOPLEVEL).defines -quiet

# Load general settings
source ../scripts/settings.tcl -quiet

# Load the library paths and definitions for this technology
source ../libraries/libraries.$TECHNOLOGY.tcl -quiet
source ../libraries/libraries.$SC_TECHNOLOGY.tcl -quiet
source ../libraries/libraries.$SRAM_TECHNOLOGY.tcl -quiet
if {$design(FULLCHIP_OR_MACRO)=="FULLCHIP"} {
    source ../libraries/libraries.$IO_TECHNOLOGY.tcl -quiet
}

enics_message "Suppressing the following messages that are design specific"  
enics_message "$design(DESIGN_SUPPRESS_MESSAGES_GENUS)" low
suppress_messages $design(DESIGN_SUPPRESS_MESSAGES_GENUS)

#############################################
#       Print values to debug file
#############################################
set var_list {runtype phys_synth_type}
set dic_list {paths tech tech_files design}
enics_print_debug_data w $debug_file "after everything was loaded" $var_list $dic_list



###########################
#      Read MMMC          # 
###########################
enics_start_stage "init_design"

# Suppress messages
enics_message "Suppressing the following messages that are reported due to the library definitions:" 
enics_message "$tech(LIB_SUPPRESS_MESSAGES_GENUS)" low
suppress_messages $tech(LIB_SUPPRESS_MESSAGES_GENUS)

# Load MMMC File
# --------------
enics_message "Loading MMMC File"
read_mmmc $design(mmmc_view_file)



##############################
#    Read LEF files          #
##############################
# Suppress messages
enics_message "Suppressing the following messages that are reported due to the LEF definitions:" 
enics_message "$tech(LEF_SUPPRESS_MESSAGES_GENUS)" low
suppress_messages $tech(LEF_SUPPRESS_MESSAGES_GENUS)

# Read LEFs
# ---------
enics_message "Loading the library abstracts"
read_physical -lef $tech_files(ALL_LEFS)


##########################
# Read RTL
##########################
enics_start_stage "read_rtl"

enics_message "Suppressing the following messages that are design specific" 
enics_message "$design(DESIGN_SUPPRESS_MESSAGES_GENUS)" low
suppress_messages $design(DESIGN_SUPPRESS_MESSAGES_GENUS)

set_db init_hdl_search_path $design(hdl_search_paths)
read_hdl -language sv -f $design(read_hdl_list)



#############################
# Elaborate and Init Design #
#############################
# Elaborate
# ---------
enics_start_stage "elaborate"
elaborate $design(TOPLEVEL) ;#-update

# Check Design
# ------------
enics_start_stage "post_elaboration"
enics_message "Checking design post elaboration"
check_design -unresolved
check_design -all > $design(synthesis_reports)/post_elaboration/check_design_post_elab.rpt
if {[check_design -status]} {
    Puts "ENICSINFO: ############# There is an issue with check_design. You better look at it! ###########"
}

# Init Design
# -----------
enics_message "Running init_design in an MMMC flow"
init_design


# Check Timing
# ------------
enics_message "Checking timing intent (lint) after init design"
check_timing_intent
check_timing_intent -verbose > $design(synthesis_reports)/post_elaboration/check_timing_post_elab.rpt


# save elaborated design
# ---------------------
write_design -base_name $design(export_dir)/post_elaboration/$design(TOPLEVEL)


##########################
#  For physical synthesis
##########################

# Optionally read floorplan
# -------------------------
if {$phys_synth_type == "floorplan"} { 
    # You need to read a .def file for the floorplan to enable physical synthesis 
    enics_message "Loading the floorplan def"
    read_def $design(floorplan_def)
    check_floorplan -detailed
}


##########################
#     Synthesize
##########################
enics_start_stage "synthesis"

# Define cost groups (reg2reg, in2reg, reg2out, in2out)
# -----------------------------------------------------
enics_default_cost_groups
enics_report_timing $design(synthesis_reports)/post_elaboration/

# clock gating settings
# ---------------------
set_db [get_db design:$design(TOPLEVEL)] .lp_clock_gating_min_flops 8
set_db [get_db design:$design(TOPLEVEL)] .lp_clock_gating_style latch 

# Don't use scan cells
# --------------------
enics_message "Setting Don't Use on scan flip flops"
foreach cell [get_db lib_cells -if {.scan_enable_pins!=""}] {set_db $cell .avoid true}

# Set Synthesis Efforts
# ---------------------
set_db syn_generic_effort low        ; # low|medium|high|express
set_db syn_map_effort low            ; # low|medium|high
set_db syn_opt_effort low            ; # low|medium|high|extreme
set_db opt_spatial_effort standard   ; # legacy|standard|extreme
set_db design_power_effort high      ; # none|low|high

if {$phys_synth_type == "floorplan"} {
    # Synthesize to generics and place generics in floorplan
    enics_start_stage "syn_generic" 
    syn_generic -physical 
    # Map to technology
    enics_start_stage "technology_mapping"
    syn_map -physical
    enics_report_timing $design(synthesis_reports) 
    # Post synthesis optimization
    enics_start_stage "post_syn_opt"
    syn_opt -spatial
} else {
    # Synthesize to generics with square floorplan 0.7 utilization
    enics_start_stage "syn_generic"
    syn_generic -create_floorplan -physical
    # Map to technology
    enics_start_stage "technology_mapping"
    syn_map -physical
    enics_report_timing $design(synthesis_reports)
    enics_start_stage "post_syn_opt"
    syn_opt -spatial
}



#############################
#     Post Synthesis Reports
#############################
enics_default_cost_groups ; # Run this again because it lost the cost group definitions
enics_report_timing $design(synthesis_reports) 
set post_synth_reports [list \
    report_area \
    report_gates \
    report_hierarchy \
    report_clock_gating \
    report_design_rules \
    report_dp \
    report_qor \
]
foreach rpt $post_synth_reports {
    enics_message "$rpt" medium
    $rpt
    $rpt > "$design(synthesis_reports)/$this_run(stage)/${rpt}.rpt"
}

#############################
#   Exporting the Design
#############################
enics_start_stage "export_design"
mkdir -pv $design(export_dir)/post_synth


# Write out a database for loading in Innovus/Voltus/Tempus
# ---------------------------------------------------------
enics_message "Exporting the design Database for Innovus/Voltus to $design(postsyn_db_base_name)"
write_design -base_name $design(postsyn_db_base_name) -innovus -db
enics_message "Exporting the design Database for restoring in Genus to $design(export_dir)/post_synth/restore_in_genus"
write_design -base_name $design(export_dir)/post_synth/restore_in_genus

# Write out a netlist for simulation or Innovus
# ---------------------------------------------
enics_message "Writing the post synthesis netlist to $design(postsyn_netlist)"
write_netlist > $design(postsyn_netlist)

# Write out SDF for backannotation simulation
# -------------------------------------------
enics_message "Writing the post synthesis SDF"
write_sdf > $design(postsyn_sdf)

