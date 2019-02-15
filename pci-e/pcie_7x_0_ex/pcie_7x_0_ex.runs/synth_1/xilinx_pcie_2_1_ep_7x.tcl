# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7k410tffg900-2

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.cache/wt [current_project]
set_property parent.project_path d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/EP_MEM.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/PIO.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/PIO_EP.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/PIO_EP_MEM_ACCESS.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/PIO_RX_ENGINE.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/PIO_TO_CTRL.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/PIO_TX_ENGINE.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/pcie_7x_0_pipe_clock.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/pcie_7x_0_support.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/pcie_app_7x.v
  d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/xilinx_pcie_2_1_ep_7x.v
}
read_ip -quiet d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/pcie_7x_0.xci
set_property used_in_implementation false [get_files -all d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/source/pcie_7x_0-PCIE_X0Y0.xdc]
set_property used_in_implementation false [get_files -all d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/synth/pcie_7x_0_ooc.xdc]
set_property used_in_implementation false [get_files -all d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/ip_0/pcie_7x_0_fastConfigFIFO.xdc]
set_property used_in_implementation false [get_files -all d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/pcie_7x_0_ex.srcs/sources_1/ip/pcie_7x_0/ip_0/pcie_7x_0_fastConfigFIFO_clocks.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/xilinx_pcie_7x_ep_x8g2.xdc
set_property used_in_implementation false [get_files d:/Documents/FPGA-Miner/xilinx-study/pci-e/pg054/pcie_ex2-tendompcie/pcie_7x_0_ex/imports/xilinx_pcie_7x_ep_x8g2.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top xilinx_pcie_2_1_ep_7x -part xc7k410tffg900-2


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef xilinx_pcie_2_1_ep_7x.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file xilinx_pcie_2_1_ep_7x_utilization_synth.rpt -pb xilinx_pcie_2_1_ep_7x_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
