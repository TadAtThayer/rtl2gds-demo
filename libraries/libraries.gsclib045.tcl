# Library setting for your Standard Cell libraries

# Libs
set paths(STANDARD_CELLS_RVT)	$paths(SC_ROOT)/GSCLIB045
lappend paths(LIB_paths) "$paths(STANDARD_CELLS_RVT)/lib/"
set paths(STANDARD_CELLS_LVT)	$paths(SC_ROOT)/gsclib045_lvt
lappend paths(LIB_paths) "$paths(STANDARD_CELLS_LVT)/lib/"
set paths(STANDARD_CELLS_HVT)	$paths(SC_ROOT)/gsclib045_hvt
lappend paths(LIB_paths) "$paths(STANDARD_CELLS_HVT)/lib/"

# General
set tech(LIBRARY_HAS_ENDCAPS) "YES"
set tech(STANDARD_CELL_SITE) CoreSite
set tech(STANDARD_CELL_VDD) VDD
set tech(STANDARD_CELL_GND) VSS

# LEFS

set tech_files(TECHNOLOGY_LEF) $paths(TECHNOLOGY_FILES)/lef/gsclib045_tech.lef
    set tech_files(ALL_LEFS) [list $tech_files(TECHNOLOGY_LEF)] ; # list of all lefs for init_design
set tech_files(STANDARD_CELLS_RVT_LEF) $paths(STANDARD_CELLS_RVT)/lef/gsclib045_macro.lef
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELLS_RVT_LEF)
set tech_files(STANDARD_CELLS_LVT_LEF) $paths(STANDARD_CELLS_LVT)/lef/gsclib045_lvt_macro.lef
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELLS_LVT_LEF)
set tech_files(STANDARD_CELLS_HVT_LEF) $paths(STANDARD_CELLS_HVT)/lef/gsclib045_hvt_macro.lef
    lappend tech_files(ALL_LEFS) $tech_files(STANDARD_CELLS_HVT_LEF)
# Get rid of annoying messages due to loading standard cell library LEFs
lappend tech(LEF_SUPPRESS_MESSAGES_GENUS) {*}"message-1 message-2"
lappend tech(LEF_SUPPRESS_MESSAGES_INNOVUS) {*}"message-3 message-4"

# Temperatures for Corners
set tech(TEMPERATURE_BC) -40
set tech(TEMPERATURE_TC) 25
set tech(TEMPERATURE_WC) 125

# Libs
set tech_files(STANDARD_CELLS_RVT_BC_LIB) $paths(STANDARD_CELLS_RVT)/timing/fast_vdd1v0_basicCells.lib
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD_CELLS_RVT_BC_LIB)] ; # list of all libs for init_design
set tech_files(STANDARD_CELLS_RVT_WC_LIB) $paths(STANDARD_CELLS_RVT)/timing/slow_vdd1v0_basicCells.lib
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD_CELLS_RVT_WC_LIB)] ; # list of all libs for init_design
set tech_files(STANDARD_CELLS_RVT_TC_LIB) $paths(STANDARD_CELLS_RVT)/timing/slow_vdd1v0_basicCells.lib
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD_CELLS_RVT_TC_LIB)] ; # list of all libs for init_design

set tech_files(STANDARD_CELLS_LVT_BC_LIB) $paths(STANDARD_CELLS_LVT)/timing/fast_vdd1v0_basicCells_lvt.lib
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD_CELLS_LVT_BC_LIB)] ; # list of all libs for init_design
set tech_files(STANDARD_CELLS_LVT_WC_LIB) $paths(STANDARD_CELLS_LVT)/timing/slow_vdd1v0_basicCells_lvt.lib
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD_CELLS_LVT_WC_LIB)] ; # list of all libs for init_design
set tech_files(STANDARD_CELLS_LVT_TC_LIB) $paths(STANDARD_CELLS_LVT)/timing/slow_vdd1v0_basicCells_lvt.lib
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD_CELLS_LVT_TC_LIB)] ; # list of all libs for init_design

set tech_files(STANDARD_CELLS_HVT_BC_LIB) $paths(STANDARD_CELLS_HVT)/timing/fast_vdd1v0_basicCells_hvt.lib
    lappend tech_files(ALL_BC_LIBS) [list $tech_files(STANDARD_CELLS_HVT_BC_LIB)] ; # list of all libs for init_design
set tech_files(STANDARD_CELLS_HVT_WC_LIB) $paths(STANDARD_CELLS_HVT)/timing/slow_vdd1v0_basicCells_hvt.lib
    lappend tech_files(ALL_WC_LIBS) [list $tech_files(STANDARD_CELLS_HVT_WC_LIB)] ; # list of all libs for init_design
set tech_files(STANDARD_CELLS_HVT_TC_LIB) $paths(STANDARD_CELLS_HVT)/timing/slow_vdd1v0_basicCells_hvt.lib
    lappend tech_files(ALL_TC_LIBS) [list $tech_files(STANDARD_CELLS_HVT_TC_LIB)] ; # list of all libs for init_design
# Get rid of annoying messages due to loading standard cell library LIBs
lappend tech(LIB_SUPPRESS_MESSAGES_GENUS) {*}"message-5 message-6"
lappend tech(LIB_SUPPRESS_MESSAGES_INNOVUS) {*}"message-7 message-8"
  

# Verilog
set tech_files(STANDARD_CELLS_RVT_VERILOG) $paths(STANDARD_CELLS_RVT)/verilog/rvt.v
    lappend tech_files(ALL_BEHAVIORAL_MODELS) [list $tech_files(STANDARD_CELLS_RVT_VERILOG)]
set tech_files(STANDARD_CELLS_LVT_VERILOG) $paths(STANDARD_CELLS_LVT)/verilog/lvt.v
    lappend tech_files(ALL_BEHAVIORAL_MODELS) [list $tech_files(STANDARD_CELLS_LVT_VERILOG)]
set tech_files(STANDARD_CELLS_HVT_VERILOG) $paths(STANDARD_CELLS_HVT)/verilog/hvt.v
    lappend tech_files(ALL_BEHAVIORAL_MODELS) [list $tech_files(STANDARD_CELLS_HVT_VERILOG)]

# OA
set tech_files(STANDARD_CELLS_RVT_OA) $paths(STANDARD_CELLS_RVT)/oa
set tech_files(STANDARD_CELLS_LVT_OA) $paths(STANDARD_CELLS_LVT)/oa
set tech_files(STANDARD_CELLS_HVT_OA) $paths(STANDARD_CELLS_HVT)/oa

# Annoying messages



# For SDC
set tech(SDC_DRIVING_CELL) BUFFX4  
set tech(CCOPT_DRIVING_PIN) BUFFX4/Y
set tech(SDC_LOAD_PIN) BUFFX4/A


# Physical Cells
set tech(WELLTAP) ""; # Well tap cells
set tech(WELLTAP_RULE) 20.0 ; # Well tap spacing DRC (in microns)
set tech(TIEHI) "Tie Hi Cell"
set tech(TIELO) "Tie Low Cell"
set tech(TIE_MAX_FANOUT) 20 ; # Maximum fanout for tie cells
set tech(TIE_MAX_DISTANCE) 20 ; # Maximum distance between tie cell and gate in microns
set tech(FILLERS) "" ;  # Filler cells (widest to most narrow)
set tech(FILLTIE) "" ;  # Fill+Tap cells (widest to most narrow)
set tech(DECAP) "" ;  # Decap cells (widest to most narrow) 
set tech(DECAPTIE) "" ;  # Decap+Tap cells (widest to most narrow)
set tech(ANTENNA_DIODE) "" ; # Antenna fix diode cells
set tech(ENDCAPS_right) "" ; # Endcap cells for right side of rows
set tech(ENDCAPS_left) "" ; # Endcap cells for left side of rows
                        # There may be many more of these for advanced processes


# Clock Cells (Used during CTS/CCOpt)
set tech(CLOCK_BUFFERS) "" ; # List of clock buffers to use during CCOpt
set tech(CLOCK_INVERTERS) "" ; # List of clock inverters to use during CCOpt
set tech(CLOCK_GATES) "" ; # List of integrated clock gate cells to use during CCOpt
set tech(CLOCK_LOGIC) "" ; # List of clock logic cells to use during CCOpt
set tech(CLOCK_DELAYS) "" ; # List of clock delay cells to use during CCOpt and possibly hold fixing




# Technology specific settings:
# Check library documentation if you shouldn't set specific setting

#############################################
#       Print values to debug file
#############################################
set var_list {}
set dic_list {paths tech tech_files}
enics_print_debug_data a $debug_file libraries.$SC_TECHNOLOGY.tcl $var_list $dic_list
