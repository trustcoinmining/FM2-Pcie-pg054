/**
 * File        - DemoBoard.cpp
 * Description - See header of ./DemoBoard.h
 *
 * Copyright (c) 2012, Xilinx
 * All rights reserved.
 */

// STL headers
#include <iostream>

// Class header
#include "DemoBoard.h"
#include "../common/xilinx_fpc_constants.h"

// Namespace using directives
using std::cout;
using std::endl;
using std::string;

// Implementation of class DemoBoard

// Static member initialization

const uint16_t DemoBoard::k_XilinxVendorId = XILINX_VENDOR_ID;

const uint16_t DemoBoard::k_DemoBoardDeviceId  = FPC_DEVICE_ID;

const string DemoBoard::k_DemoBinFilename  = "fpc_demo.bin";

const string DemoBoard::k_BoardDescription = FPC_DESCRIPTION;

DemoBoard::DemoBoard_Creator DemoBoard::creationAgent;

// Virtual Destructor

DemoBoard::~DemoBoard(void) {
}

// Public overrides from class XilinxFpcDevice

const string& DemoBoard::getDeviceName(void) const {
  return(k_BoardDescription);
}

void DemoBoard::configure(string binFileName) {
  // Configure the 2nd stage with the demonstration bit file.
  // This implements a simple yet demonstrable "user design" loaded into the 
  // FPGA via PCIe.

  // if file=<binfile> has not been specified, use DemoBoard default
  if(binFileName == "") {
    binFileName = k_DemoBinFilename;
  }

  configUserPartition(binFileName);
}

// Private constructor

DemoBoard::DemoBoard(const string &nodeName, int32_t nodeHandle) :
  XilinxFpcDevice(nodeName, nodeHandle) {
}

// Private type implementations

// Class DemoBoard::Creator

// Constructor

DemoBoard::DemoBoard_Creator::DemoBoard_Creator(void) :
  Creator(k_XilinxVendorId, k_DemoBoardDeviceId) {
}

DemoBoard::DemoBoard_Creator::~DemoBoard_Creator(void) {
}

// Public overrides from class XilinxFpcDevice::Creator

XilinxFpcDevice*
DemoBoard::DemoBoard_Creator::createInstance(const string &nodeName, int32_t nodeHandle) {
  // Create and return an instance of the parent class
  return(new DemoBoard(nodeName, nodeHandle));
}
