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
// File       : pcie_7x_0_tandem_cpler_ctl_arb.v
// Version    : 3.3
// Description:  PCIe Fast Configuration Tandem Cpler Ctl Arb
//
//
//
//--------------------------------------------------------------------------------
`timescale 1ps/1ps

module pcie_7x_0_tandem_cpler_ctl_arb #(
  parameter C_DATA_WIDTH = 64,                // RX/TX interface data width
  parameter TCQ = 1
) (
  input               clk,
  input               rst_n,

  input               m_axis_rx_tready,
  input               m_axis_rx_tvalid,
  input               m_axis_rx_tlast,
  input        [21:0] m_axis_rx_tuser,

  input               user_app_rdy_req,
  // Register must be initialized to zero so that it becomes a one-shot register
  output reg          user_app_rdy_gnt = 1'b0,

  input               req_compl,
  input               compl_done
  );

  reg                 rx_busy;
  reg                 rx_completion_busy;
  wire                rx_start_busy;

  // trigger for start of packet
  assign rx_start_busy = (m_axis_rx_tready && m_axis_rx_tvalid);

  //  Create the busy signals
  //    - rx_busy
  //        - goes high one cycle after start_busy
  //        - goes low 1 cycle after valid goes low
  //        - The one cycle delay is relevant in order to allow for a completion start in that cycle.
  //    - rx_completion_busy
  //        - goes high one cycle after req_completion
  //        - goes low on the same clock that done asserts
  //        - The one cycle delay is not required since no dependent transactions will follow.
  always @ ( posedge clk ) begin
    if (!rst_n ) begin
      rx_busy <= #TCQ 1'b0;
      rx_completion_busy <= #TCQ 1'b0;
    end else begin
      rx_busy <= #TCQ (rx_start_busy || rx_busy) ? m_axis_rx_tvalid : 1'b0;
      rx_completion_busy <= #TCQ (req_compl || rx_completion_busy) ? ~compl_done : 1'b0;
    end
  end

  //  Grant access to user_app when the following are true:
  //  1) RX path is not in the middle of something (indicated by !rx_start_busy)
  //  2) We've waited for 1 clock cycle after a last RX activity to make sure a TX CPL 
  //     doesn't begin (indicated by !rx_busy)
  //  3) TX path is not in the middle of something (indicated by !rx_completion_busy)
  //  4) User app has requested control (indicated by user_app_rdy_req)
  //  Oneshot-register, after it goes high it will stay high
  always @ ( posedge clk ) begin
    // req_completion should not be required since it shold overlap with rx_busy, but it can't hurt.
    if (user_app_rdy_req && !rx_start_busy && !rx_busy && !req_compl && !rx_completion_busy) begin
      user_app_rdy_gnt <= #TCQ 1'b1;
    end
  end

endmodule // pcie_7x_v1_7_tandem_cpler_ctl_arb
