set design(TOPLEVEL) "bcd_digit"
set debug_file "debug.txt"


#############################################
#       Files and Paths
#############################################
set design(workdir)           $env(PWD)
set design(project_root)      "$env(PWD)/.."
set design(inputs_dir)        "$design(project_root)/inputs"
set design(libraries_dir)     "$design(project_root)/libraries"
set design(sourcecode_dir)    "$design(project_root)/sourcecode/rtl"
set design(hdl_search_paths)  ". $design(sourcecode_dir)"
set design(read_hdl_list)     "$design(sourcecode_dir)/../bcd_digit_src_list.txt"
set design(testbench_dir)     "$design(project_root)/sourcecode/tb"
set design(scripts_dir)       "$design(project_root)/scripts"
set design(export_dir)        "$design(project_root)/export"
set design(reports_dir)       "$design(project_root)/reports"
set design(dbs_dir)           "$design(project_root)/dbs"
set design(synthesis_reports) "$design(reports_dir)/synthesis"
set design(functional_sdc)    "$design(inputs_dir)/$design(TOPLEVEL).sdc"
set design(postsyn_netlist)   "$design(export_dir)/post_synth/$design(TOPLEVEL).postsyn.v"
set design(postsyn_db_base_name) "$design(dbs_dir)/post_synth/$design(TOPLEVEL)"
set design(postsyn_db)        "$design(postsyn_db_base_name).stylus.enc"
set design(postsyn_sdf)       "$design(export_dir)/post_synth/$design(TOPLEVEL).postsyn.sdf"
set design(floorplan_def)     "$design(export_dir)/$design(TOPLEVEL).floorplan.def"
set design(postroute_netlist) "$design(export_dir)/$design(TOPLEVEL).final.v"
set design(postroute_sdf)     "$design(export_dir)/$design(TOPLEVEL).final.sdf"
set design(mmmc_view_file)    "$design(inputs_dir)/$design(TOPLEVEL).mmmc"
set design(io_file)           "$design(inputs_dir)/ioring.io"
set design(clock_tree_spec)   "$design(inputs_dir)/$design(TOPLEVEL).ccopt"




set_db init_lib_search_path /thayerfs/courses/26spring/engs084/workspace/sky130/sky130_scl_9T_0.1.2/sky130_scl_9T/lib
set_db library {sky130_ss_1.62_125_nldm.lib}
set_db init_hdl_search_path $design(hdl_search_paths)



read_hdl -language vhdl -f ../sourcecode/bcd_digit_src_list.txt

elaborate
read_sdc ../inputs/bcd_digit.sdc

syn_generic
syn_map
syn_opt
report_timing > ../reports/synthesis/timing.rpt
report_area > ../reports/synthesis/area.rpt
write_hdl > bcd_digit_gate.vhd

