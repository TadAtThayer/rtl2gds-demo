if { [info exists design(TOPLEVEL)] == 0 } {
    set design(TOPLEVEL) bcd_digit
}

set PDK_TOP /thayerfs/courses/26spring/engs084/workspace/rak/Genus_CUI_RAK


set_db init_lib_search_path [list $PDK_TOP/LIB $PDK_TOP/LEF]
set_db library {slow.lib}
set_db lef_library {gsclib045_tech.lef gsclib045_macro.lef}

set_db init_hdl_search_path [list ../sourcecode/rtl ../sourcecode/tb]

read_hdl -language vhdl -f ../sourcecode/$design(TOPLEVEL)_src_list.txt

elaborate
read_sdc ../inputs/$design(TOPLEVEL).sdc

syn_generic
syn_map
syn_opt
report_timing > ../reports/synthesis/timing.rpt
report_area > ../reports/synthesis/area.rpt
write_hdl > $design(TOPLEVEL)_gate.v

