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
## File       : pcie_7x_0_ooc.xdc
## Version    : 3.3
#
# This constraints file contains default clock frequencies to be used during out-of-context flows such as
# OOC Synthesis and Hierarchical Designs. For best results the frequencies should be modified
# to match the target frequencies. 
# This constraints file is not used in normal top-down synthesis (the default flow of Vivado)

#
create_clock -name pcie_7x_0_sys_clk -period 10 [get_ports sys_clk]
# 100/125/250 MHz

create_clock -name pcie_7x_0_pclk -period 8 [get_ports pipe_pclk_in]
# 125/250 MHz

create_clock -name pcie_7x_0_rxusrclk -period 8 [get_ports pipe_rxusrclk_in]
# 125/250 MHz 

create_clock -name pcie_7x_0_dclk -period 8 [get_ports pipe_dclk_in]
# 125 MHz

create_clock -name pcie_7x_0_usrclk1 -period 4 [get_ports pipe_userclk1_in]
create_clock -name pcie_7x_0_usrclk2 -period 4 [get_ports pipe_userclk2_in]

create_clock -name pcie_7x_0_oobclk -period 8 [get_ports pipe_oobclk_in]
# 50 MHz , 125/250 MHz
