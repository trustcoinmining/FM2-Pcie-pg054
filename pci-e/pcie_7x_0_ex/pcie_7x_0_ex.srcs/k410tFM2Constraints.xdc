### TCM-FM1 and FM2L Constraints file
#   copyright (c) 2019 https://trustcoinmining.com
#   email : info@trustfarm.net , cpplover@trustfarm.net
#   Github : https://github.com/trustcoinmining.com
#   Applied Boards : TCM-FM1 , TCM-FM2x
#   Initial Date : 30/Jan/2019
#   Version : 0.1
#
###

# Flashing Speed information.
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

# Sys Clock Pins
#
# Board System - wide clock name is bd_sys_clk_p,n
#
set_property PACKAGE_PIN            D27         [get_ports {bd_sys_clk_p}]
set_property PACKAGE_PIN            C27         [get_ports {bd_sys_clk_n}]
set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports {bd_sys_clk_p}]
set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports {bd_sys_clk_n}]

# in case of PCI-E Xilinx IP uses same name of sys_clk_p,n
# Here , we set sys_clk_p,n means PCI-e sys_clk_pn
#
set_property PACKAGE_PIN U8  [get_ports sys_clk_p]
# set_property PACKAGE_PIN U8  [get_ports sys_clk_n]
# Sys Reset Pins
# set_property PULLUP true [get_ports sys_rst_n]
set_property PACKAGE_PIN B18 [get_ports bd_sys_rst_n]
# set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]

# PCIe RESET / WAKEB
set_property LOC    M27	        [get_ports sys_rst_n]	
set_property LOC    N30	        [get_ports EXT_PCIE_WAKE_B]	

# USB to Serial UART 
set_property LOC            AA22            [get_ports {RxD}]
set_property LOC            AA23            [get_ports {TxD}]
set_property LOC            AC20	        [get_ports {USB_RTS}]
set_property LOC            AC21	        [get_ports {USB_CTS}]
set_property IOSTANDARD     LVCMOS25        [get_ports {RxD}]
set_property IOSTANDARD     LVCMOS25        [get_ports {TxD}]
set_property IOSTANDARD     LVCMOS25        [get_ports {USB_RTS}]
set_property IOSTANDARD     LVCMOS25        [get_ports {USB_CTS}]

set_property LOC K18 [get_ports leds[0]]
set_property LOC J18 [get_ports leds[1]]
set_property LOC H20 [get_ports leds[2]]
set_property LOC G20 [get_ports leds[3]]
set_property LOC J17 [get_ports leds[4]]

set_property IOSTANDARD LVTTL [get_ports leds[0]]
set_property IOSTANDARD LVTTL [get_ports leds[1]]
set_property IOSTANDARD LVTTL [get_ports leds[2]]
set_property IOSTANDARD LVTTL [get_ports leds[3]]
set_property IOSTANDARD LVTTL [get_ports leds[4]]

# set_property PACKAGE_PIN J18 [get_ports {EXT_LEDS[1]}]
# set_property PACKAGE_PIN H20 [get_ports {EXT_LEDS[2]}]
# set_property PACKAGE_PIN G20 [get_ports {EXT_LEDS[3]}]
# set_property PACKAGE_PIN J17 [get_ports {EXT_LEDS[4]}]
# set_property PACKAGE_PIN H17 [get_ports {EXT_LEDS[5]}]
# set_property PACKAGE_PIN J19 [get_ports {EXT_LEDS[6]}]
# set_property PACKAGE_PIN H19 [get_ports {EXT_LEDS[7]}]


