set_property SRC_FILE_INFO {cfile:D:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendomprom/pcie_7x_0_ex/imports/xilinx_pcie_7x_ep_x8g1.xdc rfile:../../../imports/xilinx_pcie_7x_ep_x8g1.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:93 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC [get_package_pins -of_objects [get_sites IOB_X0Y250]] [get_ports sys_rst_n]
set_property src_info {type:XDC file:1 line:110 export:INPUT save:INPUT read:READ} [current_design]
set_property LOC IBUFDS_GTE2_X0Y1 [get_cells refclk_ibuf]
set_property src_info {type:XDC file:1 line:111 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN U8 [get_ports sys_clk_p]
set_property src_info {type:XDC file:1 line:123 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 1 [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0]
set_property src_info {type:XDC file:1 line:124 export:INPUT save:INPUT read:READ} [current_design]
set_case_analysis 0 [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1]
set_property src_info {type:XDC file:1 line:144 export:INPUT save:INPUT read:READ} [current_design]
create_pblock clk_logic_pblock_boot
add_cells_to_pblock [get_pblocks clk_logic_pblock_boot] [get_cells -quiet [list pcie_7x_0_support_i/pipe_clock_i/GND pcie_7x_0_support_i/pipe_clock_i/RST0_i pcie_7x_0_support_i/pipe_clock_i/S00_i pcie_7x_0_support_i/pipe_clock_i/VCC pcie_7x_0_support_i/pipe_clock_i/dclk_i_bufg.dclk_i pcie_7x_0_support_i/pipe_clock_i/gen3_reg1_i pcie_7x_0_support_i/pipe_clock_i/gen3_reg1_reg pcie_7x_0_support_i/pipe_clock_i/gen3_reg2_i pcie_7x_0_support_i/pipe_clock_i/gen3_reg2_reg pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1 pcie_7x_0_support_i/pipe_clock_i/pclk_sel1_i pcie_7x_0_support_i/pipe_clock_i/pclk_sel1_i__0 pcie_7x_0_support_i/pipe_clock_i/pclk_sel2_i pcie_7x_0_support_i/pipe_clock_i/pclk_sel_i pcie_7x_0_support_i/pipe_clock_i/pclk_sel_i__0 pcie_7x_0_support_i/pipe_clock_i/pclk_sel_i__1 pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_i {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[0]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[1]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[2]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[3]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[4]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[5]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[6]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg1_reg[7]} pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_i {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[0]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[1]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[2]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[3]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[4]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[5]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[6]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_reg2_reg[7]} pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_i {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[0]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[1]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[2]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[3]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[4]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[5]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[6]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg1_reg[7]} pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_i {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[0]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[1]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[2]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[3]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[4]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[5]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[6]} {pcie_7x_0_support_i/pipe_clock_i/pclk_sel_slave_reg2_reg[7]} pcie_7x_0_support_i/pipe_clock_i/txoutclk_i.txoutclk_i pcie_7x_0_support_i/pipe_clock_i/userclk1_i1.usrclk1_i1]]
resize_pblock [get_pblocks clk_logic_pblock_boot] -add {SLICE_X100Y150:SLICE_X103Y199}
set_property BOOT_BLOCK 1 [get_pblocks clk_logic_pblock_boot]
set_property src_info {type:XDC file:1 line:156 export:INPUT save:INPUT read:READ} [current_design]
create_pblock pcie_7x_0_ext_mmcm_pblock_boot
add_cells_to_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] [get_cells -quiet [list pcie_7x_0_support_i/pipe_clock_i/mmcm_i]]
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {IN_FIFO_X0Y12:IN_FIFO_X0Y15}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {MMCME2_ADV_X0Y3:MMCME2_ADV_X0Y3}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {OUT_FIFO_X0Y12:OUT_FIFO_X0Y15}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {PHASER_IN_PHY_X0Y12:PHASER_IN_PHY_X0Y15}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {PHASER_OUT_PHY_X0Y12:PHASER_OUT_PHY_X0Y15}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {PHASER_REF_X0Y3:PHASER_REF_X0Y3}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {PHY_CONTROL_X0Y3:PHY_CONTROL_X0Y3}
resize_pblock [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot] -add {PLLE2_ADV_X0Y3:PLLE2_ADV_X0Y3}
set_property BOOT_BLOCK 1 [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot]
