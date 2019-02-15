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
// File       : pcie_7x_0_fast_cfg_init_cntr.v
// Version    : 3.3
//--
//-- Description: This logic uses the EOS pin of the STARUP primitive to detect
//--              when the stage2 logic has completed configuration.
//--
//--              When the stage2 logic has been completed tandem_stage2_rdy
//--              will assert.
//--              The clock is only used for the clock domain crossing registers
//--              that are enabled with the INCLUDE_CDC_REGS==1 parameter.
//--              The reset (active high) will cause the tandem_stage2_rdy signal
//--              to de-assert and wait for a stage2 bitstream; at which point
//--              tandem_stage2_rdy will again become asserted.
//--
//------------------------------------------------------------------------------
`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module pcie_7x_0_fast_cfg_init_cntr #(
  parameter INCLUDE_CDC_REGS = 1,
  parameter TCQ              = 1
) (
  // Tandem Stage2 Detect Interface
  input            clk,                // Clock for domain crossing registers (If INCLUDE_CDC_REGS==0 this pin is unconnected)
  input            rst,                // Reset (active-high) deasserts tandem_stage2_rdy, it will assert after another bitstream is loaded
  output wire      tandem_stage2_rdy,  // Asserts when stage2 has been fully programmed
  // STARTUP primitive interface 
  output           startup_cfgclk,     // 1-bit output: Configuration main clock output
  output           startup_cfgmclk,    // 1-bit output: Configuration internal oscillator clock output
  output wire      startup_eos,        // 1-bit output: Active high output signal indicating the End Of Startup
  output           startup_preq,       // 1-bit output: PROGRAM request to fabric output
  input            startup_clk,        // 1-bit input: User start-up clock input
  input            startup_gsr,        // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
  input            startup_gts,        // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
  input            startup_keyclearb,  // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
  input            startup_pack,       // 1-bit input: PROGRAM acknowledge input
  input            startup_usrcclko,   // 1-bit input: User CCLK input
  input            startup_usrcclkts,  // 1-bit input: User CCLK 3-state enable input
  input            startup_usrdoneo,   // 1-bit input: User DONE pin output control
  input            startup_usrdonets   // 1-bit input: User DONE 3-state enable output 
);

// Wire declarations
// stage2_start reg must have a zero initialization value to prevent optimization of this logic
reg stage2_start = 1'b0;
reg stage2_end = 1'b0;
(* ASYNC_REG = "TRUE" *)
reg cdc_reg1 = 1'b0;
(* ASYNC_REG = "TRUE" *)
reg cdc_reg2 = 1'b0;

  // The startup is added so that the End Of Startup (EOS) signal can be monitored.
  // This will allow the design to detect the end of the stage2 bitstream and then
  // shift control from stage1 to the stage2 user design.
  // STARTUPE2: 7 Series
  STARTUPE2 #(
    .PROG_USR("FALSE"),              // Activate program event security feature. Requires encrypted bitstreams.
    .SIM_CCLK_FREQ(0.0)              // Set the Configuration Clock Frequency(ns) for simulation.
  ) startup_inst (
    .CFGCLK(startup_cfgclk),         // 1-bit output: Configuration main clock output
    .CFGMCLK(startup_cfgmclk),       // 1-bit output: Configuration internal oscillator clock output
    .EOS(startup_eos),               // 1-bit output: Active high output signal indicating the End Of Startup.
    .PREQ(startup_preq),             // 1-bit output: PROGRAM request to fabric output
    .CLK(startup_clk),               // 1-bit input: User start-up clock input
    .GSR(startup_gsr),               // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
    .GTS(startup_gts),               // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
    .KEYCLEARB(startup_keyclearb),   // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
    .PACK(startup_pack),             // 1-bit input: PROGRAM acknowledge input
    .USRCCLKO(startup_usrcclko),     // 1-bit input: User CCLK input
    .USRCCLKTS(startup_usrcclkts),   // 1-bit input: User CCLK 3-state enable input
    .USRDONEO(startup_usrdoneo),     // 1-bit input: User DONE pin output control
    .USRDONETS(startup_usrdonets)    // 1-bit input: User DONE 3-state enable output
  );

  // Start of stage2 detect register w/ Async Reset:
  // Register is driven 1 at the falling edge of eos which
  // marks the beginning of the stage2 bitstream.
  always @ (negedge startup_eos or posedge rst) begin
    if (rst) begin
      stage2_start <= #TCQ 1'b0;
    end else begin
      stage2_start <= #TCQ 1'b1;
    end
  end

  // End of stage2 detect register w/ Axync Reset:
  // Register is driven 1 at the rising edge of eos (after
  // stage2_start is asserted) which marks the end of the
  // stage2 bitstream.
  always @ (posedge startup_eos or posedge rst) begin
    if (rst) begin
      stage2_end <= #TCQ 1'b0;
    end else begin
      stage2_end <= #TCQ (stage2_start || stage2_end);
    end
  end

  // Generate the clock domain crossing register if INCLUDE_CDC_REGS="1"
  generate
    if (INCLUDE_CDC_REGS==1) begin
      // Clock Domain Crossing registers w/ Sync Reset
      always @ (posedge clk) begin
        if (rst) begin
          cdc_reg1 <= #TCQ 1'b0;
          cdc_reg2 <= #TCQ 1'b0;
        end else begin
          cdc_reg1 <= stage2_end;
          cdc_reg2 <= cdc_reg1;
        end
      end
      // assign the output
      assign tandem_stage2_rdy = cdc_reg2;
    end else begin
      // assign the output
      assign tandem_stage2_rdy = stage2_end;
    end
  endgenerate

endmodule
