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
// File       : pcie_7x_0_data_transfer.v
// Version    : 3.3
//
// Module Name:    pcie_7x_0_data_transfer
// Description: 
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module pcie_7x_0_data_transfer (
   input          trn_clk,
   input          conf_clk,
   input          trn_reset_n,
   // Test-Signals for analysing incoming data-stream
   input          dis_data_trf_conf,
   input          conf_FIFO_clr,
   // Interface to APP_BDG(driven by trn_clk)
   input          wr_rqst,
   input [31:0]   wr_data,
   output reg     pause,
//   output reg     conf_error,   // bring out to a register?
//   input          rst_conf_error,
   // Interface to ICAP_ACC(driven by conf_clk)
   output [31:0]  conf_data,
   output reg     conf_enable,
   output         pr_done
//   input          PUSH_BACK,
//   inout [35:0]   control0
);

//   wire             FIFO_overflow;
//   wire             FIFO_underflow;
//   reg              FIFO_underflow_set;
//   reg              FIFO_underflow_t;
//   reg              FIFO_underflow_r;
   wire             FIFO_empty;
   reg              FIFO_rd_en;
   reg              FIFO_rd_en_prev;
//   reg              PUSH_BACK_prev;
   wire             FIFO_prog_full;
   reg              start_config;
//   reg              start_config_t;
   reg              end_config;
//   reg              end_config_reg;

   parameter [31:0] SOC_1 = 32'h53545254;   //"STRT"
   parameter [31:0] EOC_1 = 32'h454E445F;   //"END_"
   parameter [31:0] WOC_2 = 32'h434F4E46;   //"CONF"
   parameter [31:0] WOC_3 = 32'h50434965;   //"PCIe"

   reg              soc_1_fd;
   reg              soc_1_fd_1dly;
   reg              soc_1_fd_2dly;
   reg              eoc_1_fd;
   reg              eoc_1_fd_1dly;
   reg              eoc_1_fd_2dly;
   reg              soc_2_fd, eoc_2_fd;
   reg              soc_2_fd_1dly, eoc_2_fd_1dly;
   reg              soc_3_fd, eoc_3_fd;

   wire [31:0]      conf_data_fifo;

   reg [4:0]        entries;
//   reg              th_entry;

   reg              pr_done_c;
   reg              purge;
   reg              conf_FIFO_clr_sync, conf_FIFO_clr_sync1;

//   wire [71:0]      trig;

   //DIN(31 downto 24) => wr_data(7 downto 0),
   //DIN(23 downto 16) => wr_data(15 downto 8),
   //DIN(15 downto 8) => wr_data(23 downto 16),
   //DIN(7 downto 0) => wr_data(31 downto 24),

   always @(posedge conf_clk) begin
      conf_FIFO_clr_sync = conf_FIFO_clr;
      conf_FIFO_clr_sync1 = conf_FIFO_clr_sync;
   end

   pcie_7x_0_fastConfigFIFO fastConfigFIFO_i (
      .rst       (conf_FIFO_clr_sync1),
      .wr_clk    (trn_clk),
      .rd_clk    (conf_clk),
      .din       (wr_data),
      .wr_en     (wr_rqst),
      .rd_en     (FIFO_rd_en),
      .dout      (conf_data_fifo),
      .full      (),
      .empty     (FIFO_empty),
      .prog_full (FIFO_prog_full)
   );

   always @(posedge trn_clk or negedge trn_reset_n) begin
      if (!trn_reset_n) entries <= 5'b0;
      else if (FIFO_empty) begin
         entries <= 5'b0;
//         th_entry <= 1'b0;
      end else if (wr_rqst) entries <= entries + 1;
//      if (entries > 5'b01010) th_entry <= 1'b1;
   end

   assign conf_data = !dis_data_trf_conf ? conf_data_fifo : 32'b0;

   /////////////////////////////////////////////////////////////////////////////
   //  Detect start_of_config and end_of_config-pattern
   //  "STRTCONFPCIe" and "END_CONF_PCIe"
   /////////////////////////////////////////////////////////////////////////////
   always @(posedge trn_clk or negedge trn_reset_n) begin
      if (!trn_reset_n) begin
         soc_1_fd <= 1'b0;
         soc_1_fd_1dly <= 1'b0;
         soc_1_fd_2dly <= 1'b0;
         soc_2_fd <= 1'b0;
         soc_2_fd_1dly <= 1'b0;
         soc_3_fd <= 1'b0;
      end else if (wr_rqst) begin
         soc_1_fd <= 1'b0;
         if (wr_data == SOC_1) soc_1_fd <= 1'b1;
         soc_1_fd_1dly <= soc_1_fd;
         soc_1_fd_2dly <= soc_1_fd_1dly;

         soc_2_fd <= 1'b0;
         if (wr_data == WOC_2) soc_2_fd <= 1'b1;
         soc_2_fd_1dly <= soc_2_fd;

         soc_3_fd <= 1'b0;
         if (wr_data == WOC_3) soc_3_fd <= 1'b1;
      end
   end

   always @(posedge conf_clk) begin
      if (FIFO_rd_en_prev == 1'b1) begin
         eoc_2_fd <= 1'b0;
         if (conf_data_fifo == WOC_2) eoc_2_fd <= 1'b1;
         eoc_2_fd_1dly <= eoc_2_fd;

         eoc_3_fd <= 1'b0;
         if (conf_data_fifo == WOC_3) eoc_3_fd <= 1'b1;

         eoc_1_fd <= 1'b0;
         if (conf_data_fifo == EOC_1) eoc_1_fd <= 1'b1;
         eoc_1_fd_1dly <= eoc_1_fd;
         eoc_1_fd_2dly <= eoc_1_fd_1dly;
      end
   end

   always @(posedge trn_clk or negedge trn_reset_n) begin
      if (!trn_reset_n) begin
         end_config <= 1'b0;
         start_config <= 1'b0;
      end else begin
         if (soc_1_fd_2dly && soc_2_fd_1dly && soc_3_fd) start_config <= 1'b1;
         else if (end_config) start_config <= 1'b0;

         if (eoc_1_fd_2dly && eoc_2_fd_1dly && eoc_3_fd) end_config <= 1'b1;
         if (!start_config) end_config <= 1'b0;
      end
   end

//   always @(posedge trn_clk) start_config_t <= start_config;

   /////////////////////////////////////////////////////////////////////////////
   // Signal the completion of the configuration to reconfigurable module
   /////////////////////////////////////////////////////////////////////////////
   always @(posedge trn_clk or negedge trn_reset_n) begin
      if (!trn_reset_n) pr_done_c <= 1'b0;
      else if (end_config) pr_done_c <= 1'b1;
   end

   assign pr_done = pr_done_c;

   /////////////////////////////////////////////////////////////////////////////
   // Back-pressure of the FIFO, request to stop FIFO-writing
   /////////////////////////////////////////////////////////////////////////////
   always @(posedge trn_clk or negedge trn_reset_n) begin
      if (!trn_reset_n) pause <= 1'b0;
      else if (FIFO_prog_full) pause <= 1'b1;
      else pause <= 1'b0;
   end

   /////////////////////////////////////////////////////////////////////////////
   // Error-detection and -signaling on FIFO overflows/underflows
   // (signaled back to PCIe-interface)
   /////////////////////////////////////////////////////////////////////////////

   // Transfer underflow into PCIe-clock domain:

//   always @(posedge conf_clk or negedge trn_reset_n) begin
//      if (!trn_reset_n) FIFO_underflow_set <= 1'b0;
//      else begin
//         if (FIFO_underflow) FIFO_underflow_set <= 1'b1;
//         if (rst_conf_error) FIFO_underflow_set <= 1'b0;
//      end
//   end

//   always @(posedge trn_clk or negedge trn_reset_n) begin
//      if (!trn_reset_n) begin
//         FIFO_underflow_t <= 1'b0;
//         FIFO_underflow_r <= 1'b0;
//         conf_error <= 1'b0;
//      end else begin
//         if (rst_conf_error) begin
//            FIFO_underflow_t <= 1'b0;
//            FIFO_underflow_r <= 1'b0;
//            conf_error <= 1'b0;
//         end else begin
//            FIFO_underflow_t <= FIFO_underflow_set;
//            FIFO_underflow_r <= FIFO_underflow_t;
//            if (FIFO_underflow_r || FIFO_overflow) conf_error <= 1'b1;
//            else conf_error <= 1'b0;
//         end
//      end
//   end

   /////////////////////////////////////////////////////////////////////////////
   // Interface to ICAP_ACC
   /////////////////////////////////////////////////////////////////////////////
   always @(posedge conf_clk) begin
      FIFO_rd_en_prev <= FIFO_rd_en;
//      PUSH_BACK_prev <= PUSH_BACK;

/*
      // once the FIFO is not empty anymore, a conf-request to the ICAP is started
      if (!FIFO_empty) ACC_RQST <= 1'b1;
      if (!start_config_t && FIFO_empty) ACC_RQST <= 1'b0;
*/

//      if ACC_GRTD='1' and PUSH_BACK='0' and FIFO_empty='0' then
//         FIFO_rd_en <= '1' after 100 ps;
//      end if;

      conf_enable <= FIFO_rd_en;
//      if (PUSH_BACK) conf_enable <= 1'b0;
//      else if (PUSH_BACK_prev == 1'b1 & PUSH_BACK == 1'b0) conf_enable <=  1'b1;
//      else conf_enable <=  FIFO_rd_en;
   end


//   always @(PUSH_BACK or FIFO_empty or th_entry)
   always @(FIFO_empty) begin
//      if (!PUSH_BACK && !FIFO_empty && th_entry)
      if (!FIFO_empty) FIFO_rd_en <= 1'b1;
      else FIFO_rd_en <=  1'b0;
   end

/*
   always @(posedge conf_clk) begin
      if (FIFO_empty) purge <= 1'b0;
      else if (end_config_reg) purge <= 1'b1;
   end

   always @(posedge trn_clk) begin
      if (end_config) end_config_reg <= 1'b1;   // simont cross clock
      else if (start_config) end_config_reg <= 1'b0;
   end
*/

/*
   ila_dt_72 ila_dt_72_i(.CONTROL(control0), .CLK(trn_clk), .TRIG0(trig));

   assign trig[31:0] = wr_data;
   assign trig[32] = th_entry;
   assign trig[33] = end_config;
   assign trig[34] = wr_rqst;
   assign trig[35] = FIFO_overflow;
   assign trig[36] = FIFO_prog_full;
   assign trig[37] = FIFO_underflow;
   assign trig[38] = FIFO_rd_en;
   assign trig[39] = FIFO_empty;
   assign trig[71:40] = conf_data_fifo;
*/

endmodule
