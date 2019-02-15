vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib
vlib questa_lib/msim/xpm
vlib questa_lib/msim/fifo_generator_v13_1_4

vmap xil_defaultlib questa_lib/msim/xil_defaultlib
vmap xpm questa_lib/msim/xpm
vmap fifo_generator_v13_1_4 questa_lib/msim/fifo_generator_v13_1_4

vlog -work xil_defaultlib -64 -sv \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work fifo_generator_v13_1_4 -64 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_4 -64 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_4 -64 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work xil_defaultlib -64 \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/ip_0/sim/pcie_7x_0_fastConfigFIFO.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_eq.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_drp.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_rate.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_reset.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_sync.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gtp_pipe_rate.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gtp_pipe_drp.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gtp_pipe_reset.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_user.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pipe_wrapper.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_qpll_drp.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_qpll_reset.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_qpll_wrapper.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_rxeq_scan.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_top.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_core_top.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_rx_null_gen.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_rx_pipeline.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_rx.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_top.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_tx_pipeline.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_tx_thrtl_ctl.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_axi_basic_tx.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_7x.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_bram_7x.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_bram_top_7x.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_brams_7x.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_pipe_lane.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_pipe_misc.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie_pipe_pipeline.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gt_top.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gt_common.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gtp_cpllpd_ovrd.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gtx_cpllpd_ovrd.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gt_rx_valid_filter_7x.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_gt_wrapper.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_PIO_EP_FPC.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_PIO_EP_MA_FPC.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_PIO_FPC.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_PIO_RX_ENG_FPC.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_PIO_TO_CTRL_FPC.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_PIO_TX_ENG_FPC.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_data_transfer.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_icap_access.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_icap_pipeline.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/FPC/pcie_7x_0_pr_loader.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_tandem_cpler_ctl_arb.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_fast_cfg_init_cntr.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0_pcie2_top.v" \
"../../../../pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/sim/pcie_7x_0.v" \

vlog -work xil_defaultlib \
"glbl.v"

