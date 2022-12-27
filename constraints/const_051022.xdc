#SMA
set_property PACKAGE_PIN AN31 [get_ports start]
set_property IOSTANDARD LVCMOS18 [get_ports start]
set_property PACKAGE_PIN AP31 [get_ports stop]
set_property IOSTANDARD LVCMOS18 [get_ports stop]

#buttons
#set_property PACKAGE_PIN AR40 [get_ports start]     #N
#set_property IOSTANDARD LVCMOS18 [get_ports start]
#set_property PACKAGE_PIN AP40 [get_ports stop]     #S
#set_property IOSTANDARD LVCMOS18 [get_ports stop]

#set_property PACKAGE_PIN AW40 [get_ports test]
#set_property IOSTANDARD LVCMOS18 [get_ports test]


set_property PACKAGE_PIN AU38 [get_ports enable]
set_property IOSTANDARD LVCMOS18 [get_ports enable]
#E
set_property CLOCK_DEDICATED_ROUTE TRUE [get_nets start_IBUF]
set_property CLOCK_DEDICATED_ROUTE TRUE [get_nets stop_IBUF]

#set_property PACKAGE_PIN AM39 [get_ports led_1]
#set_property IOSTANDARD LVCMOS18 [get_ports led_1]
#set_property PACKAGE_PIN AN39 [get_ports led_2]
#set_property IOSTANDARD LVCMOS18 [get_ports led_2]
#set_property PACKAGE_PIN AR37 [get_ports led_3]
#set_property IOSTANDARD LVCMOS18 [get_ports led_3]
#set_property PACKAGE_PIN AT37 [get_ports led_4]
#set_property IOSTANDARD LVCMOS18 [get_ports led_4]
#set_property PACKAGE_PIN AR35 [get_ports led_5]
#set_property IOSTANDARD LVCMOS18 [get_ports led_5]

set_property PACKAGE_PIN AU36 [get_ports tx]
set_property IOSTANDARD LVCMOS18 [get_ports tx]

set_property IOSTANDARD LVDS [get_ports clk_p]
set_property PACKAGE_PIN E19 [get_ports clk_p]
set_property PACKAGE_PIN E18 [get_ports clk_n]
set_property IOSTANDARD LVDS [get_ports clk_n]

set_property PACKAGE_PIN AV39 [get_ports reset_button]
set_property IOSTANDARD LVCMOS18 [get_ports reset_button]
#C

set_max_delay -through [get_ports stop] 40.000
set_max_delay -through [get_ports start] 40.000

set_max_delay -from [get_ports stop] -to [all_registers] 40.000
set_max_delay -from [get_ports start] -to [all_registers] 40.000

set_max_delay -from [all_inputs] -to [all_outputs] 60.000
#set_false_path -through [get_ports stop]
#set_false_path -through [get_ports start]

