set_max_delay 10.0 -from [all_inputs] -to [all_outputs]
set_input_delay 0.1 -clock [get_clocks *] [all_inputs]
set_output_delay 0.1 -clock [get_clocks *] [all_outputs]
set timing_report_unconstrained true

# create_clock -name clk -period 9.3 [get_ports clk]
# set_input_delay 0.5 -clock clk [all_inputs] 
# set_output_delay 0.5 -clock clk [all_outputs]
# set_max_delay 9.5 -from [all_inputs] -to [all_outputs]
# set_timing_report_unconstrained true
# set_input_transition 0.2 [all_inputs]
# set_load 0.1 [all_outputs]
