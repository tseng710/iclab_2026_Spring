###################################################################

# Created by write_sdc on Wed Apr  8 20:25:38 2026

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_wire_load_mode top
set_wire_load_model -name enG5K -library fsa0m_a_generic_core_ss1p62v125c
set_load -pin_load 0.05 [get_ports {OUT_character[11]}]
set_load -pin_load 0.05 [get_ports {OUT_character[10]}]
set_load -pin_load 0.05 [get_ports {OUT_character[9]}]
set_load -pin_load 0.05 [get_ports {OUT_character[8]}]
set_load -pin_load 0.05 [get_ports {OUT_character[7]}]
set_load -pin_load 0.05 [get_ports {OUT_character[6]}]
set_load -pin_load 0.05 [get_ports {OUT_character[5]}]
set_load -pin_load 0.05 [get_ports {OUT_character[4]}]
set_load -pin_load 0.05 [get_ports {OUT_character[3]}]
set_load -pin_load 0.05 [get_ports {OUT_character[2]}]
set_load -pin_load 0.05 [get_ports {OUT_character[1]}]
set_load -pin_load 0.05 [get_ports {OUT_character[0]}]
set_max_capacitance 0.15 [get_ports {IN_character[11]}]
set_max_capacitance 0.15 [get_ports {IN_character[10]}]
set_max_capacitance 0.15 [get_ports {IN_character[9]}]
set_max_capacitance 0.15 [get_ports {IN_character[8]}]
set_max_capacitance 0.15 [get_ports {IN_character[7]}]
set_max_capacitance 0.15 [get_ports {IN_character[6]}]
set_max_capacitance 0.15 [get_ports {IN_character[5]}]
set_max_capacitance 0.15 [get_ports {IN_character[4]}]
set_max_capacitance 0.15 [get_ports {IN_character[3]}]
set_max_capacitance 0.15 [get_ports {IN_character[2]}]
set_max_capacitance 0.15 [get_ports {IN_character[1]}]
set_max_capacitance 0.15 [get_ports {IN_character[0]}]
set_max_capacitance 0.15 [get_ports {IN_weight[14]}]
set_max_capacitance 0.15 [get_ports {IN_weight[13]}]
set_max_capacitance 0.15 [get_ports {IN_weight[12]}]
set_max_capacitance 0.15 [get_ports {IN_weight[11]}]
set_max_capacitance 0.15 [get_ports {IN_weight[10]}]
set_max_capacitance 0.15 [get_ports {IN_weight[9]}]
set_max_capacitance 0.15 [get_ports {IN_weight[8]}]
set_max_capacitance 0.15 [get_ports {IN_weight[7]}]
set_max_capacitance 0.15 [get_ports {IN_weight[6]}]
set_max_capacitance 0.15 [get_ports {IN_weight[5]}]
set_max_capacitance 0.15 [get_ports {IN_weight[4]}]
set_max_capacitance 0.15 [get_ports {IN_weight[3]}]
set_max_capacitance 0.15 [get_ports {IN_weight[2]}]
set_max_capacitance 0.15 [get_ports {IN_weight[1]}]
set_max_capacitance 0.15 [get_ports {IN_weight[0]}]
set_max_fanout 10 [get_ports {IN_character[11]}]
set_max_fanout 10 [get_ports {IN_character[10]}]
set_max_fanout 10 [get_ports {IN_character[9]}]
set_max_fanout 10 [get_ports {IN_character[8]}]
set_max_fanout 10 [get_ports {IN_character[7]}]
set_max_fanout 10 [get_ports {IN_character[6]}]
set_max_fanout 10 [get_ports {IN_character[5]}]
set_max_fanout 10 [get_ports {IN_character[4]}]
set_max_fanout 10 [get_ports {IN_character[3]}]
set_max_fanout 10 [get_ports {IN_character[2]}]
set_max_fanout 10 [get_ports {IN_character[1]}]
set_max_fanout 10 [get_ports {IN_character[0]}]
set_max_fanout 10 [get_ports {IN_weight[14]}]
set_max_fanout 10 [get_ports {IN_weight[13]}]
set_max_fanout 10 [get_ports {IN_weight[12]}]
set_max_fanout 10 [get_ports {IN_weight[11]}]
set_max_fanout 10 [get_ports {IN_weight[10]}]
set_max_fanout 10 [get_ports {IN_weight[9]}]
set_max_fanout 10 [get_ports {IN_weight[8]}]
set_max_fanout 10 [get_ports {IN_weight[7]}]
set_max_fanout 10 [get_ports {IN_weight[6]}]
set_max_fanout 10 [get_ports {IN_weight[5]}]
set_max_fanout 10 [get_ports {IN_weight[4]}]
set_max_fanout 10 [get_ports {IN_weight[3]}]
set_max_fanout 10 [get_ports {IN_weight[2]}]
set_max_fanout 10 [get_ports {IN_weight[1]}]
set_max_fanout 10 [get_ports {IN_weight[0]}]
set_max_transition 3 [get_ports {IN_character[11]}]
set_max_transition 3 [get_ports {IN_character[10]}]
set_max_transition 3 [get_ports {IN_character[9]}]
set_max_transition 3 [get_ports {IN_character[8]}]
set_max_transition 3 [get_ports {IN_character[7]}]
set_max_transition 3 [get_ports {IN_character[6]}]
set_max_transition 3 [get_ports {IN_character[5]}]
set_max_transition 3 [get_ports {IN_character[4]}]
set_max_transition 3 [get_ports {IN_character[3]}]
set_max_transition 3 [get_ports {IN_character[2]}]
set_max_transition 3 [get_ports {IN_character[1]}]
set_max_transition 3 [get_ports {IN_character[0]}]
set_max_transition 3 [get_ports {IN_weight[14]}]
set_max_transition 3 [get_ports {IN_weight[13]}]
set_max_transition 3 [get_ports {IN_weight[12]}]
set_max_transition 3 [get_ports {IN_weight[11]}]
set_max_transition 3 [get_ports {IN_weight[10]}]
set_max_transition 3 [get_ports {IN_weight[9]}]
set_max_transition 3 [get_ports {IN_weight[8]}]
set_max_transition 3 [get_ports {IN_weight[7]}]
set_max_transition 3 [get_ports {IN_weight[6]}]
set_max_transition 3 [get_ports {IN_weight[5]}]
set_max_transition 3 [get_ports {IN_weight[4]}]
set_max_transition 3 [get_ports {IN_weight[3]}]
set_max_transition 3 [get_ports {IN_weight[2]}]
set_max_transition 3 [get_ports {IN_weight[1]}]
set_max_transition 3 [get_ports {IN_weight[0]}]
set_max_delay 20  -from [list [get_ports {IN_character[11]}] [get_ports {IN_character[10]}]     \
[get_ports {IN_character[9]}] [get_ports {IN_character[8]}] [get_ports         \
{IN_character[7]}] [get_ports {IN_character[6]}] [get_ports {IN_character[5]}] \
[get_ports {IN_character[4]}] [get_ports {IN_character[3]}] [get_ports         \
{IN_character[2]}] [get_ports {IN_character[1]}] [get_ports {IN_character[0]}] \
[get_ports {IN_weight[14]}] [get_ports {IN_weight[13]}] [get_ports             \
{IN_weight[12]}] [get_ports {IN_weight[11]}] [get_ports {IN_weight[10]}]       \
[get_ports {IN_weight[9]}] [get_ports {IN_weight[8]}] [get_ports               \
{IN_weight[7]}] [get_ports {IN_weight[6]}] [get_ports {IN_weight[5]}]          \
[get_ports {IN_weight[4]}] [get_ports {IN_weight[3]}] [get_ports               \
{IN_weight[2]}] [get_ports {IN_weight[1]}] [get_ports {IN_weight[0]}]]  -to [list [get_ports {OUT_character[11]}] [get_ports {OUT_character[10]}]     \
[get_ports {OUT_character[9]}] [get_ports {OUT_character[8]}] [get_ports       \
{OUT_character[7]}] [get_ports {OUT_character[6]}] [get_ports                  \
{OUT_character[5]}] [get_ports {OUT_character[4]}] [get_ports                  \
{OUT_character[3]}] [get_ports {OUT_character[2]}] [get_ports                  \
{OUT_character[1]}] [get_ports {OUT_character[0]}]]
