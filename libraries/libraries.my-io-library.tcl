# Library definitions for your IO Libraries

set tech_files(IO_NAME) my-io-library

set paths(IO_dir) <path to IO library installation>
set paths(IO_libs) $paths(IO_dir)/<path to IO .lib files>
set paths(IO_lefs) $paths(IO_dir)/<path to IO .lef files>

# Libs
# Create lists of .lib files to be used for each corner
# For example "ALL_WC_LIBS" will have all the .lib files of the WC corner
# We can then simplify the MMMC file, by just using this list for library_set definition
set tech_files(IO_WC_LIB) $paths(IO_libs)/$tech_files(IO_NAME)wc.lib
        lappend tech_files(ALL_WC_LIBS) $tech_files(IO_WC_LIB)
set tech_files(IO_TC_LIB) $paths(IO_libs)/$tech_files(IO_NAME)tc.lib
        lappend tech_files(ALL_TC_LIBS) $tech_files(IO_TC_LIB)
set tech_files(IO_BC_LIB) $paths(IO_libs)/$tech_files(IO_NAME)bc.lib
        lappend tech_files(ALL_BC_LIBS) $tech_files(IO_BC_LIB)
# Add annoying messages to suppress that occur due to the loading of these IO files
lappend tech(LIB_SUPPRESS_MESSAGES_GENUS)   {*}"message-1 message-2"
lappend tech(LIB_SUPPRESS_MESSAGES_INNOVUS) {*}"message-3"

# Verilog
set tech_files(IO_VERILOG) $paths(IO_dir)/<path-to-behavioral-model>/$tech_files(IO_NAME).v 

# LEF
set tech_files(IO_LEF) $paths(IO_lefs)/$tech_files(IO_NAME).lef
set tech_files(IO_ANTENNA_LEF) $paths(IO_lefs)/antenna_$IO_METAL_STACK.lef
        lappend tech_files(ALL_LEFS) $tech_files(IO_LEF) $tech_files(IO_ANTENNA_LEF)
# Add annoying messages to suppress that occur due to the loading of these IO files
lappend tech(LEF_SUPPRESS_MESSAGES_GENUS)   {*}"message-4"
lappend tech(LEF_SUPPRESS_MESSAGES_INNOVUS) {*}"message-5 message-6"

# PG pins
# These are the names of the power/ground pins in the IO library
set tech(IO_VDDCORE) VDD
set tech(IO_GNDCORE) VSS
set tech(IO_VDDIO) VDDPST
set tech(IO_GNDIO) VSS

##############################
## SDC default definitions: ##
##############################
set tech(SDC_DRIVING_CELL)  <one of the digital IOs from the library>
set tech(CCOPT_DRIVING_PIN) $tech(SDC_DRIVING_CELL)/C
set tech(SDC_LOAD_PIN)      $tech(SDC_DRIVING_CELL)/PAD

set tech(EXTERNAL_SDC_LOAD)    50; # Number in pF


# Others
set tech(IO_FILLERS) "io-filler1 io-filler2 io-filler3" ; # sort the list from widest to most narrow
set tech(IO_SITE) pad ; # The name of the SITE from the LEF

#############################################
#       Print values to debug file
#############################################
set var_list {}
set dic_list {paths tech tech_files}
enics_print_debug_data a $debug_file libraries.$IO_TECHNOLOGY.tcl $var_list $dic_list
