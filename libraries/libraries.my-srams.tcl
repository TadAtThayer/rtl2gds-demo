# These are the technology definitions for your compiled SRAM instances
#

# Here is a small example automation to update the .lib/.lef lists for all your memory instances
# Assuming you adhered to some specific notation.
#   In this example, we have two SRAM cuts, called sp_hde_16384_M32 and sp_hde_16384_M16
# Library/LEF setting for Compiled memories

set tech(SRAM_MUX)     [ list "M32"     "M16" ];		 # Used to differentiate various memory macro MUX-ing options
set tech(SRAM_SIZE)    [ list "16384"   "16384" ] ;		 # Used to differentiate various memory macro MUX-ing options
set tech(SRAM_FLAVOR)  [ list "hde"     "hde" ] ;		 # Used to differentiate various memory macro MUX-ing options
foreach M $tech(SRAM_MUX) S $tech(SRAM_SIZE) F $tech(SRAM_FLAVOR) {
    set m [string tolower $M]
    set path_name "../mem_gen/SP_${S}X32/${M}/"
    set inst_name "sp_${F}_${S}_${m}"
    lappend tech_files(ALL_LEFS) "${path_name}${inst_name}.lef"
    lappend tech_files(ALL_WC_LIBS)  "${path_name}${inst_name}_<ss_corner>.lib"
    lappend tech_files(ALL_TC_LIBS)  "${path_name}${inst_name}_<tt_corner>.lib"
    lappend tech_files(ALL_BC_LIBS)  "${path_name}${inst_name}_<ff_corner>.lib"
    #lappend design(hdl_search_paths) "$design(project_root)/mem_gen/SP_${S}X32/${M}"
}

# Get rid of annoying messages due to loading these memory cuts
lappend tech(LIB_SUPPRESS_MESSAGES_GENUS) {*}"message-1 message-2"
lappend tech(LEF_SUPPRESS_MESSAGES_GENUS) {*}"message-3"

# ARM Power Pin names
set tech(SRAM_VDDCORE_PIN)      "VDDCE"
set tech(SRAM_VDDPERIPHERY_PIN) "VDDPE"
set tech(SRAM_GND_PIN)          "VSSE"


set var_list {}
set dic_list {tech path tech_files}
enics_print_debug_data a $debug_file libraries.$SRAM_TECHNOLOGY.tcl $var_list $dic_list
