set_property DONT_TOUCH true [get_cells -hier -filter {NAME =~ *ro_bank*}]
set_property ALLOW_COMBINATORIAL_LOOPS true [get_nets -hier -filter {NAME =~ *ro_bank*}]

set_false_path -through [get_nets -hier -filter {NAME+~ *ro_bank*}]

set_false_path -to [get_pins -hier -filter {NAME =~ *ro_sampler*ff1_reg*/D}]