#======================================================
set DESIGN "SORT_IP_demo"
set CYCLE 6

#======================================================
set hdlin_auto_save_templates TRUE

analyze -f sverilog ../01_RTL/SORT_IP.v 
analyze -f sverilog ../01_RTL/SORT_IP_demo.v 


elaborate $DESIGN -parameters "IP_WIDTH=8"


rename_design ${DESIGN}_IP_WIDTH8 $DESIGN

current_design $DESIGN
link

#======================================================
set_wire_load_mode top
set_max_delay $CYCLE -from [all_inputs] -to [all_outputs]
set_load 0.05 [all_outputs]

set_max_transition      3       [all_inputs]   
set_max_capacitance     0.15    [all_inputs]   
set_max_fanout          10      [all_inputs]

#======================================================
check_design > Report/$DESIGN\.check
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

compile_ultra

#======================================================
set bus_inference_style "%s\[%d\]"
set bus_naming_style "%s\[%d\]"
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed "a-z A-Z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "a-z A-Z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule

#======================================================
set verilogout_higher_designs_first true
write -format verilog -output Netlist/$DESIGN\_SYN.v -hierarchy
write_sdf -version 3.0 -context verilog -load_delay cell Netlist/$DESIGN\_SYN.sdf -significant_digits 6


report_area
report_timing
exit