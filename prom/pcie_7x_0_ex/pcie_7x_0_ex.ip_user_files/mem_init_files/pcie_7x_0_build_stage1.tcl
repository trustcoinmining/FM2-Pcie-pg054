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
## File       : pcie_7x_0_build_stage1.tcl
## Version    : 3.3

#######################################################################################################################
# Tandem proc library starts here                                                                                     #
#######################################################################################################################

#==============================================================
# given a list of cells, returns the flattened list of cells
#==============================================================
proc flatten_cells { cells expanded } {
    upvar $expanded myexpanded
    foreach cell $cells {
	if {[get_property IS_PRIMITIVE $cell]} {
	    if {[string compare [get_property PRIMITIVE_LEVEL $cell] "LEAF"] == 0 } {
		lappend myexpanded $cell
	    } else {
#		puts "primitive but NOT LEAF = $cell"
	    }
	} else {
#	    puts "NOT a prim = $cell"
	    set childcells [get_cells -hier -filter "NAME =~ $cell/* && PRIMITIVE_LEVEL == LEAF"]
	    flatten_cells $childcells myexpanded
	}
    }
    return
}

#==============================================================
# expands the cells of a pblock; typical pblock cells are stored
#   as a hier-inst, so must be flattened.
# pblock : pblock to get the flattened cell list from
# returns: flattened cell list
#==============================================================
proc get_pblock_cells { pblock_name } {
    set expanded_cells {}
    set pbcells [get_cells -of [get_pblocks $pblock_name]]
    flatten_cells $pbcells expanded_cells
    return $expanded_cells
}

#==============================================================
#
#==============================================================
proc is_traceable { cell } {
    set type [get_property TYPE $cell]
    if { [get_property IS_SEQUENTIAL $cell] } {
	return 1
    }
    if { [string match $type "Clock"] } {
	return 1
    }
return 0
}

#==============================================================
# helper to add cells from expansion pin
# inputs
# - pin : pin to expand from
# - fbcells : cells of the initial boot_block pblock
# - active_cells : currently active cells (already visited)
#==============================================================
proc add_cells_from_pin { pin fbcells active_cells } {
    upvar $active_cells myactive_cells
    set dir [get_property DIRECTION $pin]
    set all_fan_func all_fanin
    if { [string match $dir "OUT"] } {
#    if {$dir == "OUT"} {}
	set all_fan_func all_fanout
    }
    set sequential {}
    set cells [$all_fan_func -quiet -trace all -flat -only_cells $pin]
    foreach cell $cells {
	if {[info exists myactive_cells($cell)] == 0} {
	    if { [ lsearch -exact $fbcells $cell ] == -1 } {
		if {[get_property IS_PRIMITIVE $cell] == 1} {
#		    puts "=====adding $cell"
		    set myactive_cells($cell) 1
		}
		if { [is_traceable $cell] } {
		    lappend sequential $cell
		}
	    }
	}
    }
    # now continue until primary ios are reached
    foreach sequ $sequential {
	set mypins [get_pins -of $sequ]
	foreach mypin $mypins {
	    if { [string match [get_property DIRECTION $mypin] $dir] } {
		add_cells_from_pin $mypin $fbcells myactive_cells
	    }
	}
    }
}

#==============================================================
# Given will trace forward/backwards from source/load to primary
#  io, gathering all cells in the paths.
# pin : is pin to expand from.
# Returns the expanded cell list;
# example: get_ext_boot_logic {pcie_7x_v1_6_0_i/PIPE_PCLK_IN}
#==============================================================
proc get_ext_boot_logic { pin pblock_name } {
#    puts "get_ext_boot_logic for pin=$pin of pblock=$pblock_name"
    set mypin [get_pins $pin]
    array set active_cells {}
    set fb_pblock [get_pblocks $pblock_name]
    if {$fb_pblock != ""} {
	set fbcells [get_pblock_cells $fb_pblock]
	set numfbcells [llength $fbcells]

#	set fp_name [open "fbcells.log" w]
#	foreach cell $fbcells { puts $fp_name $cell }
#	close $fp_name
	if {[llength $fbcells] != 0 } {
	    add_cells_from_pin $mypin $fbcells active_cells
	}
    }
    set cells {}
#    set fp_name [open "fast_boot_cons.log" w]
    foreach {key value} [array get active_cells] {
        if { $value == 1 } {
#	    puts $fp_name $key
	    lappend cells $key
        }
    }
#    close $fp_name
    return $cells
}
#######################################################################################################################
# Tandem proc library ends here                                                                                       #
#######################################################################################################################

#######################################################################################################################
# Tandem Build Stage1 Start                                                                                           #
#######################################################################################################################

#######################################################################################################################
# Remove the instances present in any existing PBLOCKs
#######################################################################################################################
#foreach curr_pblock [get_pblocks -quiet] {
#  delete_pblock $curr_pblock
#}

#######################################################################################################################
# System Checks and DRCs
#######################################################################################################################
set error_found 0
set error_string ""

# Error if there is not one and only one startup primitive in this design
set startupCells [get_cells -hierarchical -filter {PRIMITIVE_TYPE == OTHERS.others.STARTUPE2}]
if { [llength $startupCells] != 1 } {
  append error_string "Error: [llength $startupCells] STARTUP Primitives were found. One and only one STARTUP block\n"
  append error_string "       can be used in a design.\n"
  if { [llength $startupCells] !=0 } {
    append error_string "       The following STARTUP primitives were found:\n"
    foreach cell $startupCells {
      append error_string "         $cell\n"
    }
  } 
  set error_found 1
}

#######################################################################################################################
# Setup up variables for the PBLOCK Names
#######################################################################################################################
set pcie_core_hierarchy [get_cells -hierarchical -filter {REF_NAME == pcie_7x_0}]
set main_pblock_name pcie_7x_0_main_pblock_boot

#######################################################################################################################
# Routes between separate stage1 PBLOCKs will be traced and added to the stage1 design
# It is important that PBLOCKs which cannot contain routing be defined separately
# The default setting for a PBLOCK with the BOOT_BLOCK property set is CONTAIN_ROUTING=1
# and EXCLUDE_PLACEMENT=1.
#######################################################################################################################

#######################################################################################################################
# Create the main stage1 PBLOCK if it has not already been created
# Add sites to the main PBLOCK if they have not already been added
#######################################################################################################################
# Get the cells for the main PBLOCK
set main_pblock_cells [get_cells -hierarchical -filter {REF_NAME == pcie_7x_0}]
set main_pblock [get_pblocks -quiet -of_objects $main_pblock_cells]
if {$main_pblock == ""} {
  # The PCIe core has not been added to the Main PBLOCK. Add it here.
  # Create the main PBLOCK if it has not been created already.
  set main_pblock [get_pblocks -quiet $main_pblock_name]
  if {$main_pblock == ""} {  
    set main_pblock [create_pblock $main_pblock_name]
  }
}
set_property BOOT_BLOCK 1 $main_pblock
set main_pblock_sites [get_sites -quiet -of_objects $main_pblock]
if {$main_pblock_sites == ""} {
  # Add Sites to the PBLOCK
  resize_pblock $main_pblock -add {SLICE_X154Y150:SLICE_X181Y199 SLICE_X172Y200:SLICE_X181Y249}
  resize_pblock $main_pblock -add {DSP48_X10Y60:DSP48_X10Y79}
  resize_pblock $main_pblock -add {RAMB18_X9Y60:RAMB18_X10Y79}
  resize_pblock $main_pblock -add {RAMB36_X9Y30:RAMB36_X10Y39}
  resize_pblock $main_pblock -add {GTXE2_CHANNEL_X0Y0:GTXE2_CHANNEL_X0Y7}
  resize_pblock $main_pblock -add {GTXE2_COMMON_X0Y0:GTXE2_COMMON_X0Y1}
  resize_pblock $main_pblock -add {PCIE_X0Y0}
}
# Add Cells to the PBLOCK
add_cells_to_pblock $main_pblock $main_pblock_cells

#######################################################################################################################
# List all of the inputs that are requied for the stage1 PCIe design to function properly. This 
# should include clocks, reset, and control logic. These pins will be traced and any primitives
# found must be added to a stage1 PBLOCK. 
#######################################################################################################################
unset -nocomplain trace_ports
lappend trace_ports "${pcie_core_hierarchy}/sys_clk"
lappend trace_ports "${pcie_core_hierarchy}/sys_rst_n"
lappend trace_ports "${pcie_core_hierarchy}/pipe_pclk_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_dclk_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_userclk1_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_userclk2_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_rxusrclk_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_rxoutclk_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_mmcm_lock_in"
lappend trace_ports "${pcie_core_hierarchy}/pipe_mmcm_rst_n"
lappend trace_ports "${pcie_core_hierarchy}/pipe_oobclk_in"

#######################################################################################################################
# Trace all the primitives that are neccissary for stage1 to function properly
#######################################################################################################################
# Trace the specified ports to get the required primitives
unset -nocomplain traced_primitives
foreach trace_port $trace_ports {
  # Trace the port to primary IO to gather all the required primitives
  set new_traced_primitives [get_ext_boot_logic $trace_port $main_pblock_name]
  foreach cell $new_traced_primitives {
    lappend traced_primitives $cell
  }
}

# Add internal STARTUP primitive to the traceed list 
set startup_inst [get_cells ${pcie_core_hierarchy}/inst/inst/pcie_7x_0_fast_cfg_init_cntr_i/startup_inst]
lappend traced_primitives $startup_inst
# Remove the strartup from the main pblock
remove_cells_from_pblock -quiet $main_pblock_name $startup_inst

# Make the traced cell list unique
unset -nocomplain unique_traced_primitives
foreach cell $traced_primitives { set unique_traced_primitives($cell) 1 }
set traced_primitives [lsort [ array names unique_traced_primitives ] ]

#puts "**** traced_primitives ****"
#puts "[join $traced_primitives \n]"
#puts "******************************"

#######################################################################################################################
# Add the primitives to the desire PBlock
#######################################################################################################################
# Add all of the BUFG and BUFGCTRL primitives to the BUFG PBLOCK
# This PBLOCK intentionally does not containt the module name so
# that multiple PCIe cores will use the same bufg_pblock and it
# will be defined the same way in both cores.
set bufg_pblock [get_pblocks -quiet bufg_pblock_boot]
if {$bufg_pblock == ""} {
  set bufg_pblock [create_pblock bufg_pblock_boot]
}
set_property BOOT_BLOCK 1 $bufg_pblock
# Add the BUFG sites to the BUFG PBLOCK
resize_pblock -add {BUFGCTRL_X0Y0:BUFGCTRL_X0Y31} $bufg_pblock
# Get the BUFG primitives
set bufg_cells [get_cells -hierarchical -filter { PRIMITIVE_TYPE == CLK.gclk.BUFG || PRIMITIVE_TYPE == CLK.gclk.BUFGCTRL } ]
# Remove each buffer from a PBLOCK if it is assinged to one
foreach cell $bufg_cells {
  set curr_pblock [get_pblocks -quiet -of_objects $cell]
  if { $curr_pblock != "" } {
    remove_cells_from_pblock -quiet $curr_pblock $cell
  }
}

# Add all of the Buffers to the BUFG PBLOCK
add_cells_to_pblock $bufg_pblock $bufg_cells

# Add all of the BSCAN primitives to the BSCAN PBLOCK
# This PBLOCK intentionally does not containt the module name so
# that multiple PCIe cores will use the same bscan_pblock and it
# will be defined the same way in both cores.
set bscan_pblock [get_pblocks -quiet bscan_pblock_boot]
if {$bscan_pblock == ""} {
  set bscan_pblock [create_pblock bscan_pblock_boot]
}
set_property BOOT_BLOCK 1 $bscan_pblock
# Add the BSCAN sites to the BSCAN PBLOCK
resize_pblock -add {BSCAN_X0Y0:BSCAN_X0Y3} $bscan_pblock
# Get the BSCAN primitives
set bscan_cells [get_cells -quiet -hierarchical -filter { PRIMITIVE_TYPE == OTHERS.others.BSCANE2 } ]
if { $bscan_cells != "" } {
  puts "**** INFO: BSCAN Primitives were found: $bscan_cells ****" 
  # Remove each BSCAN from a PBLOCK if it is assinged to one
  foreach cell $bscan_cells {
    set curr_pblock [get_pblocks -quiet -of_objects $cell]
    if { $curr_pblock != "" } {
      remove_cells_from_pblock -quiet $curr_pblock $cell
    }
  }
  # Add all of the BSCAN primitives to the BSCAN PBLOCK
  add_cells_to_pblock $bscan_pblock $bscan_cells
} else {
  puts "**** INFO: No BSCAN Primitives in this design ****"
}

# Filter the Traced primitives into their respective PBLOCKS
set pblock_count 0
set invalid_pblock_primitives ""
foreach traced_primitive $traced_primitives {
  set primitive [get_cells $traced_primitive]
  set type [get_property PRIMITIVE_TYPE $primitive]
  switch -nocase -glob $type {
    *MMCME2_ADV {
      #puts "*** matched MMCM $primitive"
      # Create and add the PBLOCK for the MMCM
      # Do nothing if the primitive is already in a stage1 PBLOCK
      if { [get_pblocks -quiet -of_objects $primitive] == "" || [get_property -quiet BOOT_BLOCK [get_pblocks -of_objects $primitive]] != 1 } {
        # The primitive is not already in a stage1 PBLOCK
        # This primitive should be added to a stage1 PBLOCK in another core or in the user constraints.
        set error_found 1
        lappend invalid_pblock_primitives $primitive
       
      }
    }
    *STARTUPE2 {
      #puts "*** matched STARTUP $primitive"
      # Create a stage1 PBLOCK that will be used for the STARTUP primitve
      set startup_pblock [get_pblocks -quiet startup_pblock_boot]
      if {$startup_pblock == ""} {  
        set startup_pblock [create_pblock startup_pblock_boot]
      }
      set_property BOOT_BLOCK 1 $startup_pblock
      # Add the required sites to the stage1 PBLOCK
      resize_pblock -add {STARTUP_X0Y0} $startup_pblock
      # Add the STARTUP primitve to the pblock
      add_cells_to_pblock $startup_pblock $primitive
    }
    *IBUF* {
      #puts "*** matched IBUF $primitive"
      # Dynamically Create a PBLOCK for each IBUF and IBUFDS at the site where the pin is LOC'ed
      # These PBLOCKs are intentially named after the primitive so that each primitive is 
      # associated with one and only one pblock.
      set curr_pblock [get_pblocks -quiet ${primitive}_pblock_boot]
      if { $curr_pblock == "" } {
        set curr_pblock [create_pblock ${primitive}_pblock_boot]
      }
      set_property BOOT_BLOCK 1 $curr_pblock
      incr pblock_count
      set ibuf_site [get_property -quiet LOC $primitive]
      # Error if the IOB does not have a LOC constraint
      if { $ibuf_site == "" } {
        set error_found 1
        append error_string "ERROR: IBUF \"$primitive\" must have a LOC constraint.\n"
        append error_string "       Please add this constraint to your .xdc file.\n"
      } else {
        # Resize the PBLOCK and add the IOB to it
        resize_pblock -quiet -add $ibuf_site $curr_pblock
        add_cells_to_pblock -quiet $curr_pblock $primitive
      }
    } 
    *BUFG* {
      #puts "*** matched BUFG $primitive"
      # Do nothing here because we already added the BUFGs to the BUFG PBLOCK 
    }
    *GND {
      #puts "*** matched GND $primitive"
      # Do nothing 
    }
    *VCC {
      #puts "*** matched VCC $primitive"
      # Do nothing 
    }
    "" {
      #puts "*** matched Hierarchy $primitive"
      # Do nothing 
    }
    default {
      #puts "*** matched default $primitive"
      # Do nothing if the primitive is already in a stage1 PBLOCK
      if { [get_pblocks -quiet -of_objects $primitive] == "" || [get_property -quiet BOOT_BLOCK [get_pblocks -of_objects $primitive]] != 1 } {
        # The primitive is not already in a stage1 PBLOCK
        # This primitive should be added to a stage1 PBLOCK in another core or in the user constraints.
        set error_found 1
        lappend invalid_pblock_primitives $primitive
      }
    }
  }
}

#######################################################################################################################
# Error Reporting 
#######################################################################################################################
# The following user primitives were found and must be added to a stage1 PBLOCK
# in the user constraints file.
if { [llength $invalid_pblock_primitives] } {
  append error_string "Error: The following primitive must be added to a stage1 PBLOCK"
  foreach primitive $invalid_pblock_primitives {
    append error_string "\n         Cell \"$primitive\" of Type \"[get_property PRIMITIVE_TYPE $primitive]\""
  }
  append error_string "\n       This should be done in the user constraints file through the"
  append error_string "\n       following commands"
  append error_string "\n         set custom_pblock \[create_pblock <pblock name>\]"
  append error_string "\n         set_property BOOT_BLOCK 1 \$custom_pblock"
  append error_string "\n         resize_pblock -add <site> \$custom_pblock"
  append error_string "\n         add_cells_to_pblock \$custom_pblock \[get_cells <primitive name>\]\n"
}

# Issue an error if any were encountered while sorting the stage1 primitives.
if { $error_found } {
  error $error_string    
}
