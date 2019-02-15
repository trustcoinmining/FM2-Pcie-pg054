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
// File       : pcie_7x_0_icap_pipeline.v
// Version    : 3.3
//
// Description:
//   Pipeline stage for ICAP data and control signals
//
// Additional Comments:
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

module pcie_7x_0_icap_pipeline #(
  parameter ICAP_WIDTH = 32,
  parameter TCQ = 1
) (
  input                        CLK,       // Pipeline clock
  input                        RST_N,     // Pipeline reset

  input  wire                  CSIB_IN,   // ICAP enable from controller
  input  wire                  RDWRB_IN,  // ICAP Rd/Wr from controller
  input  wire [ICAP_WIDTH-1:0] I_IN,      // ICAP data in from controller
  input  wire [ICAP_WIDTH-1:0] O_IN,      // ICAP data in from ICAP

  (* shreg_extract = "no" *)
  output reg                   CSIB_OUT,  // ICAP enable to ICAP
  (* shreg_extract = "no" *)
  output reg                   RDWRB_OUT, // ICAP Rd/Wr to ICAP
  (* shreg_extract = "no" *)
  output reg  [ICAP_WIDTH-1:0] I_OUT,     // ICAP data in to ICAP
  (* shreg_extract = "no" *)
  output reg  [ICAP_WIDTH-1:0] O_OUT      // ICAP data out to controller
);

  // Double flop sys_rst to cross clock domain
(* shreg_extract = "no" *)(* ASYNC_REG = "TRUE" *) reg rst_n_reg1;
(* shreg_extract = "no" *)(* ASYNC_REG = "TRUE" *) reg rst_n_reg2;


  always @(posedge CLK) begin
    rst_n_reg1 <= #TCQ RST_N;
    rst_n_reg2 <= #TCQ rst_n_reg1;
  end
  
  // Pipeline stage
  always @(posedge CLK) begin
    if(!rst_n_reg2) begin
      CSIB_OUT  <= #TCQ 1'b0;
      RDWRB_OUT <= #TCQ 1'b0;
      I_OUT     <= #TCQ 'h0;
      O_OUT     <= #TCQ 'h0;
    end else begin
      CSIB_OUT  <= #TCQ CSIB_IN;
      RDWRB_OUT <= #TCQ RDWRB_IN;
      I_OUT     <= #TCQ I_IN;
      O_OUT     <= #TCQ O_IN;
    end
  end

endmodule
