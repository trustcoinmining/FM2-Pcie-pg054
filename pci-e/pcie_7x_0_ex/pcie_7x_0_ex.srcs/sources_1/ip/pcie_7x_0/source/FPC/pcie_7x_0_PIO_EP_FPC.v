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
// File       : pcie_7x_0_PIO_EP_FPC.v
// Version    : 3.3
//
// Module Name:    pcie_7x_0_PIO_EP_FPC
// Description: Endpoint Programmed I/O module.
//              Consists of Receive and Transmit modules and a Memory Aperture
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module pcie_7x_0_PIO_EP_FPC #(
  parameter C_DATA_WIDTH = 64,            // RX/TX interface data width

  // Do not override parameters below this line
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8,              // TSTRB width
  parameter TCQ        = 1
) (

  input                         clk,
  input                         rst_n,

  // AXIS TX
  input                         s_axis_tx_tready,
  output  [C_DATA_WIDTH-1:0]    s_axis_tx_tdata,
  output  [KEEP_WIDTH-1:0]      s_axis_tx_tkeep,
  output                        s_axis_tx_tlast,
  output                        s_axis_tx_tvalid,
  output                        tx_src_dsc,

  //AXIS RX
  input   [C_DATA_WIDTH-1:0]    m_axis_rx_tdata,
  input   [KEEP_WIDTH-1:0]      m_axis_rx_tkeep,
  input                         m_axis_rx_tlast,
  input                         m_axis_rx_tvalid,
  output                        m_axis_rx_tready,
  input   [21:0]                m_axis_rx_tuser,

  output                        req_compl,
  output                        compl_done,

  input   [15:0]                cfg_completer_id,
  // New I/O for FPC
  output wire                   pr_done,
  output wire                   ICAP_ceb,
  output wire                   ICAP_wrb,
  output wire [31:0]            ICAP_din_bs,
  input wire                    conf_clk
);

    // Local wires

    wire  [10:0]      rd_addr;
    wire  [3:0]       rd_be;
    wire  [31:0]      rd_data;

    wire  [10:0]      wr_addr;
    wire  [7:0]       wr_be;
    wire  [31:0]      wr_data;
    wire              wr_en;
    wire              wr_busy;

    wire              req_compl_int;
    wire              req_compl_wd;
    wire              compl_done_int;

    wire  [2:0]       req_tc;
    wire              req_td;
    wire              req_ep;
    wire  [1:0]       req_attr;
    wire  [9:0]       req_len;
    wire  [15:0]      req_rid;
    wire  [7:0]       req_tag;
    wire  [7:0]       req_be;
    wire  [12:0]      req_addr;

    wire [31:0]       conf_data, wr_data_conf;
    wire              conf_enable, write_en;
    wire              conf_pause;
    wire [31:0]       wr_data_conf_byteswap;

	// New blocks for FPC
   
pcie_7x_0_ICAP_access ICAP_ACC (
//      .PCIe_CLK    (clk),
        .CONF_CLK    (conf_clk),
        .reset_n     (1'b1),
        .CONF_DATA   (conf_data),
        .CONF_ENABLE (conf_enable),
        .ICAP_ceb    (ICAP_ceb),
        .ICAP_wrb    (ICAP_wrb),
        .ICAP_din_bs (ICAP_din_bs)
    );

pcie_7x_0_data_transfer data_transfer_i (
        .trn_clk           (clk),
        .conf_clk          (conf_clk),
        .trn_reset_n       (rst_n),
        .dis_data_trf_conf (1'b0),
        .conf_FIFO_clr     (1'b0),
        .wr_rqst           (write_en),
        .wr_data           (wr_data_conf_byteswap),
        .pause             (conf_pause),
//      .conf_error        (conf_error),   // bring out to a register?
//      .rst_conf_error    (1'b0),
        .conf_data         (conf_data),
        .conf_enable       (conf_enable),
        .pr_done           (pr_done)
//      .control0(CONTROL_DAT_TRF)
    );
    // End new blocks for FPC

    //
    // ENDPOINT MEMORY : 8KB memory aperture implemented in FPGA BlockRAM(*)
    //
    // The Memory Access block is currently unused and could be removed
    // (along with the entire Tx chain) but would be needed if we added any
    // registers to FPC.  Might need to have ICAP data go through here again
    // in that case (ICAP data goes directly from RX Engine to data_transfer
    // to reduce latency).
pcie_7x_0_PIO_EP_MA_FPC  #(
       .TCQ( TCQ )
       ) EP_MEM_FPC_inst (
      
      .clk(clk),               // I
      .rst_n(rst_n),           // I
      
      // Read Port
      
      .rd_addr(rd_addr),     // I [10:0]
      .rd_be(rd_be),         // I [3:0]
      .rd_data(rd_data),     // O [31:0]
      
      // Write Port
      
      .wr_addr(wr_addr),     // I [10:0]
      .wr_be(wr_be),         // I [7:0]
      .wr_data(wr_data),     // I [31:0]
      .wr_en(wr_en),         // I
      .wr_busy(wr_busy),     // O
	  // New I/O for FPC
//      .post_wr_data(wr_data_conf),   // O [31:0]
      .post_wr_data(),   // O [31:0]
//      .write_en(write_en)        // O
      .write_en()        // O
      );

    //
    // Local-Link Receive Controller
    //

pcie_7x_0_PIO_RX_ENG_FPC #(
    .C_DATA_WIDTH( C_DATA_WIDTH ),
    .KEEP_WIDTH( KEEP_WIDTH ),
    .TCQ( TCQ )

  ) EP_RX_inst (

    .clk(clk),                              // I
    .rst_n(rst_n),                          // I

    // AXIS RX
    .m_axis_rx_tdata( m_axis_rx_tdata ),    // I
    .m_axis_rx_tkeep( m_axis_rx_tkeep ),    // I
    .m_axis_rx_tlast( m_axis_rx_tlast ),    // I
    .m_axis_rx_tvalid( m_axis_rx_tvalid ),  // I
    .m_axis_rx_tready( m_axis_rx_tready ),  // O
    .m_axis_rx_tuser ( m_axis_rx_tuser ),   // I

    // Handshake with Tx engine
    .req_compl(req_compl_int),              // O
    .req_compl_wd(req_compl_wd),            // O
    .compl_done(compl_done_int),            // I

    .req_tc(req_tc),                        // O [2:0]
    .req_td(req_td),                        // O
    .req_ep(req_ep),                        // O
    .req_attr(req_attr),                    // O [1:0]
    .req_len(req_len),                      // O [9:0]
    .req_rid(req_rid),                      // O [15:0]
    .req_tag(req_tag),                      // O [7:0]
    .req_be(req_be),                        // O [7:0]
    .req_addr(req_addr),                    // O [12:0]
                                            
    // Memory Write Port - wired directly to data_transfer block
	// need to change this if add any registers to FPC
    .wr_addr(wr_addr),                      // O [10:0]
    .wr_be(wr_be),                          // O [7:0]
//    .wr_data(wr_data),                      // O [31:0]
    .wr_data(wr_data_conf),                 // O [31:0]
//    .wr_en(wr_en),                          // O
    .wr_en(write_en),                       // O
//    .wr_busy(wr_busy)                       // I
    .wr_busy(conf_pause)                    // I
                                            
  );

    //
    // Local-Link Transmit Controller
    //

pcie_7x_0_PIO_TX_ENG_FPC #(
    .C_DATA_WIDTH( C_DATA_WIDTH ),
    .KEEP_WIDTH( KEEP_WIDTH ),
    .TCQ( TCQ )
  )EP_TX_inst(

    .clk(clk),                                  // I
    .rst_n(rst_n),                              // I

    // AXIS Tx
    .s_axis_tx_tready( s_axis_tx_tready ),      // I
    .s_axis_tx_tdata( s_axis_tx_tdata ),        // O
    .s_axis_tx_tkeep( s_axis_tx_tkeep ),        // O
    .s_axis_tx_tlast( s_axis_tx_tlast ),        // O
    .s_axis_tx_tvalid( s_axis_tx_tvalid ),      // O
    .tx_src_dsc( tx_src_dsc ),                  // O

    // Handshake with Rx engine
    .req_compl(req_compl_int),                // I
    .req_compl_wd(req_compl_wd),              // I
    .compl_done(compl_done_int),                // 0

    .req_tc(req_tc),                          // I [2:0]
    .req_td(req_td),                          // I
    .req_ep(req_ep),                          // I
    .req_attr(req_attr),                      // I [1:0]
    .req_len(req_len),                        // I [9:0]
    .req_rid(req_rid),                        // I [15:0]
    .req_tag(req_tag),                        // I [7:0]
    .req_be(req_be),                          // I [7:0]
    .req_addr(req_addr),                      // I [12:0]

    // Read Port

    .rd_addr(rd_addr),                        // O [10:0]
    .rd_be(rd_be),                            // O [3:0]
    .rd_data(rd_data),                        // I [31:0]

    .completer_id(cfg_completer_id)           // I [15:0]

    );

  assign req_compl  = req_compl_int;
  assign compl_done = compl_done_int;
  assign wr_data_conf_byteswap = {wr_data_conf[7:0], wr_data_conf[15:8],
                                  wr_data_conf[23:16], wr_data_conf[31:24]};

endmodule // pcie_7x_0_PIO_EP_FPC


