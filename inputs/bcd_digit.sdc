
create_clock -period 10 -name CLK [get_ports clk]
set_input_delay -clock CLK 2 [remove_from_collection [all_inputs] clk]
set_output_delay -clock CLK 3 [all_outputs]

