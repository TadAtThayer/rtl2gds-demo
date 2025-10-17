set design(TOPLEVEL) "lp_riscv_top"
set debug_file "debug.xrun.txt"

# Read in the project definitions/variables
source ../scripts/procedures.tcl
source ../inputs/$design(TOPLEVEL).defines

# Open a waveform and add the relevant signals to the waveform
database -open -shm -into waves.shm waves -default -event
# probe -create tb_lp_riscv  -depth all -tasks -functions -uvm -packed 16k -unpacked 64k -all -dynamic -memories -database waves
probe -create -database waves tb_lp_riscv -all -memories -dynamic -depth all -tasks -functions -uvm

set w [simvision waveform new]

simvision scope set $design(tb_name)
#simvision waveform add -signals *

array unset createdGroup
array set createdGroup {}
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.PAD_CLK}]}
        } ]]
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.PAD_DONE_FLAG}]}
        } ]]
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.PAD_RST_N}]}
        } ]]
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.dut.lp_riscv.instr_addr_o[31:0]}]}
        } ]]
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.dut.lp_riscv.instr_rdata_i[31:0]}]}
        } ]]
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.dut.lp_riscv.data_addr_o[31:0]}]}
        } ]]
set id [simvision waveform add -signals [subst  {
        {[format {tb_lp_riscv.dut.lp_riscv.data_rdata_i[31:0]}]}
        } ]]
simvision waveform format $id -radix %d





simvision window geometry Console 1336x500+10+700 
simvision window geometry "Design Browser 1" 1336x500+10+700
simvision window geometry "Waveform 1" 1336x400+10+25
simvision waveform xview limits 0 2000000ps

run

