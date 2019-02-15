##-----------------------------------------------------------------------------
##
## (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
## Project    : Series-7 Integrated Block for PCI Express
## File       : xilinx_pcie_7x_ep_x8g2.xdc
## Version    : 3.3
#
###############################################################################
# User Configuration 
# Link Width   - x8
# Link Speed   - gen2
# Family       - kintex7
# Part         - xc7k410t
# Package      - ffg900
# Speed grade  - -2
# PCIe Block   - X0Y0
###############################################################################
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################

###############################################################################
# User Physical Constraints
###############################################################################


###############################################################################
# Pinout and Related I/O Constraints
###############################################################################

#
# SYS reset (input) signal.  The sys_reset_n signal should be
# obtained from the PCI Express interface if possible.  For
# slot based form factors, a system reset signal is usually
# present on the connector.  For cable based form factors, a
# system reset signal may not be available.  In this case, the
# system reset signal must be generated locally by some form of
# supervisory circuit.  You may change the IOSTANDARD and LOC
# to suit your requirements and VCCO voltage banking rules.
# Some 7 series devices do not have 3.3 V I/Os available.
# Therefore the appropriate level shift is required to operate
# with these devices that contain only 1.8 V banks.
#

set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
# set_property LOC [get_package_pins -of_objects [get_sites IOB_X0Y250]] [get_ports sys_rst_n]
set_property PACKAGE_PIN B18 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]

###############################################################################
# Physical Constraints
###############################################################################
#
# SYS clock 100 MHz (input) signal. The sys_clk_p and sys_clk_n
# signals are the PCI Express reference clock. Virtex-7 GT
# Transceiver architecture requires the use of a dedicated clock
# resources (FPGA input pins) associated with each GT Transceiver.
# To use these pins an IBUFDS primitive (refclk_ibuf) is
# instantiated in user's design.
# Please refer to the Virtex-7 GT Transceiver User Guide
# (UG) for guidelines regarding clock resource selection.
#

set_property LOC IBUFDS_GTE2_X0Y3 [get_cells refclk_ibuf]
set_property PACKAGE_PIN U8 [get_ports sys_clk_p]
###############################################################################
# Timing Constraints
###############################################################################
#
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
#
# 
set_false_path -to [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0}]
set_false_path -to [get_pins {pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1}]
#
#
create_generated_clock -name clk_125mhz_x0y0 [get_pins pcie_7x_0_support_i/pipe_clock_i/mmcm_i/CLKOUT0]
create_generated_clock -name clk_250mhz_x0y0 [get_pins pcie_7x_0_support_i/pipe_clock_i/mmcm_i/CLKOUT1]
create_generated_clock -name clk_125mhz_mux_x0y0 \ 
                        -source [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0] \
                        -divide_by 1 \
                        [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]
#
create_generated_clock -name clk_250mhz_mux_x0y0 \ 
                        -source [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1] \
                        -divide_by 1 -add -master_clock [get_clocks -of [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1]] \
                        [get_pins pcie_7x_0_support_i/pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O]
#
set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux_x0y0 -group clk_250mhz_mux_x0y0

#
# Timing ignoring the below pins to avoid CDC analysis, but care has been taken in RTL to sync properly to other clock domain.
#
#
##############################################################################
# Tandem Configuration Constraints
###############################################################################

#------------------------------------------------------------------------------
# Create a stage1 Tandem PBLOCK to contain the clock logic driving the BUFG 
# MUX primitive. This logic should be located near the BUFGs in the center of 
# the device. This PBLOCK must be defined in the user constraints since
# clocking was generated external to the core.
# This PBLOCK is not identifed using the module name so that it can be used
# for other stage1 logic that must be near the center of the device. 
#------------------------------------------------------------------------------
set clk_logic_pblock [create_pblock clk_logic_pblock_boot]
set_property BOOT_BLOCK 1 [get_pblocks clk_logic_pblock_boot]
resize_pblock -add {SLICE_X100Y150:SLICE_X103Y199} $clk_logic_pblock
# Add the clock logic to the main stage1 PBLOCK
add_cells_to_pblock $clk_logic_pblock [get_cells pcie_7x_0_support_i/pipe_clock_i]

#------------------------------------------------------------------------------
# Create a stage1 Tandem PBLOCK to contain the MMCM clocking primitive. 
# This PBLOCK must be defined in the user constraints since clocking
# was generated external to the core. These commands will remove the MMCM
# from the main PBlock and add it to the MMCM PBlock
#------------------------------------------------------------------------------
set mmcm_pblock [create_pblock pcie_7x_0_ext_mmcm_pblock_boot]
set_property BOOT_BLOCK 1 [get_pblocks pcie_7x_0_ext_mmcm_pblock_boot]
# Add the MMCM and all associated primitive to the PBLOCK
resize_pblock $mmcm_pblock -add {MMCME2_ADV_X0Y3}
resize_pblock $mmcm_pblock -add {IN_FIFO_X0Y12:IN_FIFO_X0Y15}
resize_pblock $mmcm_pblock -add {OUT_FIFO_X0Y12:OUT_FIFO_X0Y15}
resize_pblock $mmcm_pblock -add {PLLE2_ADV_X0Y3}
resize_pblock $mmcm_pblock -add {PHASER_IN_PHY_X0Y12:PHASER_IN_PHY_X0Y15}
resize_pblock $mmcm_pblock -add {PHASER_OUT_PHY_X0Y12:PHASER_OUT_PHY_X0Y15}
resize_pblock $mmcm_pblock -add {PHY_CONTROL_X0Y3}
resize_pblock $mmcm_pblock -add {PHASER_REF_X0Y3}
# Add the MMCM primitive to the PBLOCK
add_cells_to_pblock $mmcm_pblock [get_cells {pcie_7x_0_support_i/pipe_clock_i/mmcm_i}]

#######################################################################################
# The commands below are examples of how to configure bitstreams for different flash 
# devices. The commands appropriate for the targeted device should be uncommented. 
#
# The CONFIGRATE clock frequency should be modified to match your application,board 
# design,and configuration interface. A higher configuration clock frequency and 
# programming bus width will configure the device more quickly to more easily meet the 
# PCI Express boot time requirement.
#
# When using BPI flash the BPI_SYNC_MODE Setting may be required depending on the 
# BPI flash used in your system design.
#
# For more information on device programming review the following documents:
#    - UG908 - Vivado Design Suite User Guide -> Programming and Debugging.
#    - UG470 - 7 Series FPGA Configuration User Guide
#    - Command Line Tools User Guide
#######################################################################################

# Update and Uncomment for BPI flash programming
#set_property CONFIG_MODE BPI16 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE <Disable|Type1|Type2> [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

# Update and Uncomment for SPIx1 flash programming
#set_property CONFIG_MODE SPIx1 [current_design]
#set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

# Update and Uncomment for SPIx4 flash programming
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_false_path -from [get_ports sys_rst_n]

###############################################################################
# End
###############################################################################
