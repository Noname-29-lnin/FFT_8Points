# set sdc_version 2.0
# set_time_unit -nanoseconds 1.0
# create_clock -name "core_clk" -period 10.0 -waveform {0 5.0} [get_ports i_clk]
# set_clock_uncertainty 0.2 [get_clocks core_clk]
# group_path -name "Input_to_Reg" -from [all_inputs] 
# group_path -name "Reg_to_Output" -to [all_outputs] 
# group_path -name "Feedthrough" -from [all_inputs] -to [all_outputs]
# set input_ports [remove_from_collection [all_inputs] {i_clk i_rst_n}]
# set_input_delay -max 2.0 -clock [get_clocks core_clk] $input_ports
# set_output_delay -max 2.0 -clock [get_clocks core_clk] [all_outputs]
# set_input_transition 0.2 [all_inputs]
# set_load 0.05 [all_outputs]
# set_false_path -from [get_ports i_rst_n]
create_clock -name i_clk -period 1000 [get_ports i_clk]
set_input_delay 0.5 -clock i_clk [all_inputs] 
set_output_delay 0.5 -clock i_clk [all_outputs]
set_max_delay 9.5 -from [all_inputs] -to [all_outputs]
set_timing_report_unconstrained true
set_input_transition 0.2 [all_inputs]
set_load 0.1 [all_outputs]
