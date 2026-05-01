# Technology settings for your Technology
#    Note that standard cell library setting are in a separate file
#    to support various standard cell libraries
#
set METAL_STACK 9F2C
set TRACKS 9T
set_db design_process_node 130 ; # used by the set_db design_tech_node command that is loaded later


set paths(PDK_ROOT) /thayerfs/courses/26spring/engs084/workspace/sky130/sky130_release_0.1.0/

# Technology Setup
set paths(SC_ROOT) $paths(PDK_ROOT)/../sky130_scl_9T_0.1.2
set paths(TECHNOLOGY_FILES) $paths(SC_ROOT)

# Parasitic Extraction 
#### set tech_files(CAPTABLE_BC) $paths(TECHNOLOGY_FILES)/<path to captables>/rcbest.captbl
#### set tech_files(CAPTABLE_TC) $paths(TECHNOLOGY_FILES)/<path to captables>/typical.captbl
#### set tech_files(CAPTABLE_WC) $paths(TECHNOLOGY_FILES)/<path to captables>/rcworst.captbl
#### set paths(QRC_ROOT) $paths(PDK_ROOT)/<path to qrc tech files>
#### set tech_files(QRCTECH_FILE_TYPICAL) $paths(QRC_ROOT)/typical/qrcTechFile
#### set tech_files(QRCTECH_FILE_CBEST) $paths(QRC_ROOT)/cbest/qrcTechFile
#### set tech_files(QRCTECH_FILE_CWORST) $paths(QRC_ROOT)/cworst/qrcTechFile
#### set tech_files(QRCTECH_FILE_RCBEST) $paths(QRC_ROOT)/rcbest/qrcTechFile
#### set tech_files(QRCTECH_FILE_RCWORST) $paths(QRC_ROOT)/rcworst/qrcTechFile
#### set tech_files(QRCTECH_FILE_BC) $tech_files(QRCTECH_FILE_RCBEST)
#### set tech_files(QRCTECH_FILE_TC) $tech_files(QRCTECH_FILE_TYPICAL)
#### set tech_files(QRCTECH_FILE_WC) $tech_files(QRCTECH_FILE_RCWORST)

# List of technology-specific messages to suppress
set tech(LIB_SUPPRESS_MESSAGES_INNOVUS) ""
set tech(LIB_SUPPRESS_MESSAGES_GENUS) ""

# TECHLEF
# Technology LEF is defined in the standard cell LEF
#   set tech_files(TECHNOLOGY_LEF) ""
#        set tech_files(ALL_LEFS) [list $tech_files(TECHNOLOGY_LEF)] ; # list of all lefs for init_design

#### # DRC Related
#### set tech(layer_names) "M0 M1 M2 M3 M4 M5 M6 M7 M8 M9" ; # update to names of your metal layers
#### set tech(row_height) XXX ; # Vertical SITE
#### set tech(grid_unit) XXX ; # Horizontal SITE
#### 
#### 
#### # Routing Rules
#### set tech(cts_top_routing_layer_top) "M6"
#### set tech(cts_bottom_routing_layer_top) "M5"
#### set tech(cts_top_routing_layer_trunk) "M6"
#### set tech(cts_bottom_routing_layer_trunk) "M5"
#### set tech(cts_top_routing_layer_leaf) "M4"
#### set tech(cts_bottom_routing_layer_leaf) "M3"
#### 
#### 
#### # List of technology-specific messages to suppress
#### set tech(LEF_SUPPRESS_MESSAGES_INNOVUS) "message-3"
#### set tech(LEF_SUPPRESS_MESSAGES_GENUS) "message-4"
#### 
#### 
#############################################
#       Print values to debug file
#############################################
set var_list {METAL_STACK TRACKS}
set dic_list {paths tech tech_files}
enics_print_debug_data a $debug_file libraries.$TECHNOLOGY.tcl $var_list $dic_list
