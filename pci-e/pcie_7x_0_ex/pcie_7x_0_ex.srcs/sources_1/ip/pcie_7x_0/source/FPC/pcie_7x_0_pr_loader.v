//-----------------------------------------------------------------------------
//
// (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Series-7 Integrated Block for PCI Express
// File       : pcie_7x_0_pr_loader.v
// Version    : 3.3
//
// Module Name:    pcie_7x_0_pr_loader
// Description:
//
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

// `define PCI_EXP_EP_OUI     24'h000A35
// `define PCI_EXP_EP_DSN_1   {{8'h1},`PCI_EXP_EP_OUI}
// `define PCI_EXP_EP_DSN_2   32'h00000001

(* DowngradeIPIdentifiedWarnings = "yes" *)
module  pcie_7x_0_pr_loader #(
   parameter C_DATA_WIDTH = 128,
   parameter KEEP_WIDTH = C_DATA_WIDTH / 8
) (

   input wire                     sys_clk,   // 250 MHz system clock
   input wire                     sys_reset,
   input wire                     lnk_up,
   input wire                     conf_clk,  // 100 MHz configuration clock

   // AXI-S interface
 
   // Tx
   input wire                     s_axis_tx_tready,
   output wire [C_DATA_WIDTH-1:0] s_axis_tx_tdata,
   output wire [KEEP_WIDTH-1:0]   s_axis_tx_tkeep,
   output wire [3:0]              s_axis_tx_tuser,
   output wire                    s_axis_tx_tlast,
   output wire                    s_axis_tx_tvalid,

   // Rx
   input wire [C_DATA_WIDTH-1:0]  m_axis_rx_tdata,
   input wire [KEEP_WIDTH-1:0]    m_axis_rx_tkeep,
   input wire                     m_axis_rx_tlast,
   input wire                     m_axis_rx_tvalid,
   output wire                    m_axis_rx_tready,
   input wire [21:0]              m_axis_rx_tuser,

   output wire                    cfg_turnoff_ok,
   input wire                     cfg_to_turnoff,      // Configuration To Turnoff (PME_TURN_Off message recvd)
   input wire [7:0]               cfg_bus_number,      // Configuration Bus Number
   input wire [4:0]               cfg_device_number,   // Configuration Device Number
   input wire [2:0]               cfg_function_number, // Configuration Function Number

   // Signals to ensure the swtich to stage2 does not happen during a PCIe transaction
   input  wire                    user_app_rdy_req,   // Request switch to stage2
   output wire                    user_app_rdy_gnt,   // Grant switch to stage2

   output wire                    pr_done,
   output wire                    ICAP_ceb,
   output wire                    ICAP_wrb,
   output wire [31:0]             ICAP_din_bs          // bitswapped version of ICAP_din
);

   //
   // Core input tie-offs
   //
   assign s_axis_tx_tuser = 4'h0;

   //
   // Programmable I/O Module
   //

pcie_7x_0_PIO_FPC #(
      .C_DATA_WIDTH (C_DATA_WIDTH)
   ) PIO_FPC_i (
      .user_clk         (sys_clk),                // input
      .user_reset       (sys_reset),              // input
      .user_lnk_up      (lnk_up),                 // input

      // AXIS
      .s_axis_tx_tready (s_axis_tx_tready),       // input
      .s_axis_tx_tdata  (s_axis_tx_tdata),        // output [C_DATA_WIDTH-1:0]
      .s_axis_tx_tkeep  (s_axis_tx_tkeep),        // output [KEEP_WIDTH-1:0]
      .s_axis_tx_tlast  (s_axis_tx_tlast),        // output
      .s_axis_tx_tvalid (s_axis_tx_tvalid),       // output
      .tx_src_dsc       (),                       // output  FIXME not used?

      .m_axis_rx_tdata  (m_axis_rx_tdata),        // input [C_DATA_WIDTH-1:0]
      .m_axis_rx_tkeep  (m_axis_rx_tkeep),        // input [KEEP_WIDTH-1:0]
      .m_axis_rx_tlast  (m_axis_rx_tlast),        // input
      .m_axis_rx_tvalid (m_axis_rx_tvalid),       // input
      .m_axis_rx_tready (m_axis_rx_tready),       // output
      .m_axis_rx_tuser  (m_axis_rx_tuser),        // input [21:0]

      .cfg_to_turnoff   (cfg_to_turnoff),         // input
      .cfg_turnoff_ok   (cfg_turnoff_ok),         // output

      .cfg_completer_id ({cfg_bus_number,
                          cfg_device_number,
                          cfg_function_number}),  // input [15:0]

      // Signals to ensure the swtich to stage2 does not happen during a PCIe transaction
      .user_app_rdy_req(user_app_rdy_req),        // Request switch to stage2
      .user_app_rdy_gnt(user_app_rdy_gnt),        // Grant switch to stage2

      .pr_done          (pr_done),                // output
      .ICAP_ceb         (ICAP_ceb),               // output
      .ICAP_wrb         (ICAP_wrb),               // output
      .ICAP_din_bs      (ICAP_din_bs),            // output [31:0]
      .conf_clk         (conf_clk)
   );

endmodule
