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
// File       : pcie_7x_0_icap_access.v
// Version    : 3.3
//
// Module Name:   pcie_7x_0_ICAP_access
// Description:
//
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns


(* DowngradeIPIdentifiedWarnings = "yes" *)
module pcie_7x_0_ICAP_access (
//    input              PCIe_CLK,
    input              CONF_CLK,
    input              reset_n,

    // signaling from and to DAT_TRF
    input [31:0]       CONF_DATA,
    input              CONF_ENABLE,
    output reg         ICAP_ceb,
    output reg         ICAP_wrb,
    output wire [31:0] ICAP_din_bs       // bitswapped version of ICAP_din
//    inout [35:0]       CONTROL0
);


    // Signals directly at ICAP-module:
//   wire                ICAP_busy;
   reg [31:0]          ICAP_din;
//   wire [31:0]         ICAP_dout;
//   wire [0:31]         ICAP_dout_bs;  // bitswapped version of ICAP_dout
//   reg [27:0]          word_cnt;      // debug counter
   //  signal CONTROL0: std_logic_vector(35 downto 0);
//   wire [71:0]         TRIG;
//   wire                sync, desync;

    ////////////////////////////////////////////////////////////////////////////
    // Accesses to the ICAP-module
    ////////////////////////////////////////////////////////////////////////////

    always @(posedge CONF_CLK or negedge reset_n)
        if (!reset_n) begin
//            word_cnt = 28'b0;
            ICAP_din <= 32'b0;
            ICAP_ceb <= 1'b1;
            ICAP_wrb <= 1'b1;
        end else begin
            ICAP_din <= CONF_DATA;

            ICAP_ceb <= ~CONF_ENABLE;
            ICAP_wrb <= 1'b0;
//          if (CONF_ENABLE) begin
//              word_cnt = word_cnt + 1;
//          end
        end

/*
   ICAP_mod ICAP(
//   .BUSY(ICAP_busy),
   .BUSY(null),
//   .O(ICAP_dout_bs),
   .O(null),
   .CE(ICAP_ceb),
   .CLK(CONF_CLK),
   .I(ICAP_din_bs),
   .WRITE(ICAP_wrb)
   );    // 32-bit data input
*/

   // endian swap data before passing to ICAP
   // generate assign statements for each bit
   generate
     begin : end_swap
        genvar i;
        for (i=0; i<=31; i=i+1) begin : mirror_i
           assign ICAP_din_bs[i] = ICAP_din[31-i];
        end
      end
   endgenerate

//   assign ICAP_dout = ICAP_dout_bs;

/*
   ila_dt_72 ila_dt_72_i(.CONTROL(CONTROL0), .CLK(CONF_CLK), .TRIG0(TRIG));

   assign TRIG[27:0] = word_cnt;
   assign TRIG[31:28] = ICAP_dout[7:4];
   assign TRIG[32] = sync;
   assign TRIG[35] = ICAP_wrb;
   assign TRIG[36] = ICAP_ceb;
   assign TRIG[37] = desync;
   assign TRIG[38] = CONF_ENABLE;
   assign TRIG[39] = ICAP_busy;
   assign TRIG[71:40] = ICAP_din_bs;
*/

endmodule

