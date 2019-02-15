/**
 * File        - XilinxFpcDevice.cpp
 * Description - See header of ./XilinxFpcDevice.h
 *
 * Copyright (c) 2012, Xilinx
 * All rights reserved.
 */

// Class header
#include "XilinxFpcDevice.h"

// STL headers
#include <iomanip>
#include <iostream>
#include <sstream>

// Standard library headers
#include <errno.h>
#include <fcntl.h>
#include <fstream>
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <unistd.h>

// Linux headers
#include "../linux_driver/xilinx_pci_fpc.h"

// Namespace using directives
using std::cerr;
using std::cout;
using std::dec;
using std::endl;
using std::filebuf;
using std::fstream;
using std::hex;
using std::ifstream;
using std::ios;
using std::list;
using std::make_pair;
using std::map;
using std::setfill;
using std::setw;
using std::string;

// Constant used to make note of an invalid node handle
#define INVALID_NODE_HANDLE (-1)

// Implementation of class XilinxFpcDevice

// Static member initialization

const string XilinxFpcDevice::FpcDeviceRootPrefix = "pci_fpc";

const string XilinxFpcDevice::FpcDeviceNodeBase = "/tmp/pci_fpc";

// Virtual Destructor

XilinxFpcDevice::~XilinxFpcDevice(void) {
}

// Public interface methods

list<XilinxFpcDevice*> XilinxFpcDevice::getInstances(void) {
  list<XilinxFpcDevice*> returnDevices;

  // Dynamically scan for devices in sysfs by class and name
  uint32_t instanceCount = 0;
  bool instanceFound;

  // Increment the instance number until no more device records are found
  do {
    char instanceChar = static_cast<char>('0' + instanceCount);
    string devName  = FpcDeviceRootPrefix + instanceChar;
    string nodeName = FpcDeviceNodeBase + instanceChar;

    // Try to create a node for the next device
    instanceFound = createNode(devName, nodeName);
    if(instanceFound) {
      // Attempt to polymorphically create an instance to abstract the device
      XilinxFpcDevice *newDevice = XilinxFpcDevice::abstractDevice(nodeName);

      // Add the object instance to the collection being returned, if one was
      // created, and unconditionally advance to the next instance number
      if(newDevice != NULL) returnDevices.push_back(newDevice);
      instanceCount++;
    }

  } while(instanceFound);

  return(returnDevices);
}

// Protected constructor

XilinxFpcDevice::XilinxFpcDevice(const string &nodeName, int32_t nodeHandle) :
  nodeName(nodeName),
  nodeHandle(nodeHandle) {
}

// Protected helper methods

void XilinxFpcDevice::configUserPartition(const std::string &binFilename) {
  struct fpc_data_block dataBlock;
  ifstream bitstreamInput;
  filebuf *bufPtr;
  int32_t ret;
  uint32_t fileSize;
  uint32_t fileWords;
  uint32_t fileBlocks;

  // Open the bitstream input file
  bitstreamInput.open(binFilename.c_str());
  if(bitstreamInput.fail()) {
    cout << "Unable to open bitstream file \"" << binFilename << "\" for reading" << endl;
    return;
  }

  // Compute the file size and the consequent number of blocks
  bufPtr = bitstreamInput.rdbuf();
  bufPtr->pubseekpos(0, ios::in);
  fileSize   = bufPtr->pubseekoff(0, ios::end, ios::in);
  fileWords  = ((fileSize / FPC_BYTES_PER_WORD) + ((fileSize % FPC_BYTES_PER_WORD) ? 1 : 0));
  fileBlocks = ((fileWords / MAX_CONFIG_BLOCK_SIZE) + ((fileWords % MAX_CONFIG_BLOCK_SIZE) ? 1 : 0));

  cout << "Configuring user partition with \"" 
       << binFilename 
       << "\": size "
       << fileSize
       << ", "
       << fileWords
       << " words, "
       << fileBlocks
       << " blocks" 
       << endl;

  // Reset the input buffer position to the beginning
  bufPtr->pubseekpos(0, ios::in);

  // Initiate a partial configuration cycle with the driver
  if((ret = ioctl(nodeHandle, IOC_INIT_CONFIG, fileWords)) != 0) {
    cerr << "Failed to complete config init I/O control to \""
         << nodeName
         << "\", error " 
         << errno
         << endl;
  }

  // Iterate, writing blocks to the driver from the bitstream file
  uint32_t wordsLeft = fileWords;
  while(wordsLeft > 0) {
    // Write maximum-sized blocks until the last one
    dataBlock.num_words = ((wordsLeft > MAX_CONFIG_BLOCK_SIZE) ? MAX_CONFIG_BLOCK_SIZE : wordsLeft);
    bitstreamInput.read(reinterpret_cast<char*>(dataBlock.block_words), 
                        (dataBlock.num_words * FPC_BYTES_PER_WORD));

    // Swap the byte endianness
/*
    for(uint32_t wordIndex = 0; wordIndex < dataBlock.num_words; wordIndex++) {
      uint32_t swappedWord = 0;

      for(uint32_t byteIndex = 0; byteIndex < sizeof(uint32_t); byteIndex++) {
        swappedWord |= (((dataBlock.block_words[wordIndex] >> (byteIndex * 8)) & 0x0FF) << ((sizeof(uint32_t) - byteIndex - 1) * 8));
      }
      cout << hex << dataBlock.block_words[wordIndex] << " becomes " << hex << swappedWord << "\n";
      dataBlock.block_words[wordIndex] = swappedWord;
    }
*/

    if((ret = ioctl(nodeHandle, IOC_CONFIG_BLOCK, &dataBlock)) != 0) {
      cerr << "Failed to complete block config I/O control to \""
           << nodeName
           << "\", error "
           << errno 
           << endl;
      break;
    }

    // Decrement the words remaining
    wordsLeft -= dataBlock.num_words;
  }
}

// Private helper methods

const bool XilinxFpcDevice::createNode(const string &devName, const string &nodeName) {
  int32_t major = 0;
  int32_t minor = 0;
  bool success;

  // Locate the device by its miscellaneous device class, returning failure
  // if the misc device does not exist.
  string devPath = "/sys/class/misc/" + devName + "/dev";
  char buf[16];
  int32_t fd = ::open(devPath.c_str(), O_RDONLY);
  if(fd < 0) return(false);

  // Create the device node pathname
  ssize_t read_bytes;

  memset(buf, 0, sizeof(buf));
  if((read_bytes = read(fd, buf, sizeof(buf))) == 0) {
    cerr << "Unable to read from sysfs entry for \""
         << devName
         << "\""
         << endl;
  }
  close(fd);
  buf[sizeof(buf)-1] = 0;
  sscanf(buf, "%d:%d", &major, &minor);
    
  // First attempt to unlink any stale node from a previous run.
  int32_t returnCode = ::unlink(nodeName.c_str());
  success = ((returnCode >= 0) | (errno == ENOENT));

  // Create the device node
  if(success) {
    returnCode = ::mknod(nodeName.c_str(), S_IFCHR | 0777, (major<<8) | minor);
    if(returnCode < 0) {
      cerr << "Error creating device node \""
           << nodeName
           << "\" at major / minor ("
           << major
           << ", "
           << minor
           << ") : "
           << strerror(errno)
           << endl;
      success = false;
    }
  }

  return(success);
}

XilinxFpcDevice*
XilinxFpcDevice::abstractDevice(const std::string &nodeName) {
  XilinxFpcDevice *retInstance = NULL;
  int32_t nodeHandle;
  int32_t retValue;

  // Open the device node for use
  if((nodeHandle = ::open(nodeName.c_str(), O_RDWR)) > 0) {
    // Opened successfully, perform an I/O control operation to obtain the
    // vendor and product ID for the board
    struct fpc_board_id board_id;

    if(ioctl(nodeHandle, IOC_GET_BOARD_ID, &board_id) != 0) {
      retValue = errno;
      cerr << "Failed to complete I/O control to \""
           << nodeName
           << "\", error "
           << retValue
           << endl;
    }

    // Construct a 32-bit tag from the two identifying values and use it to
    // locate a factory creator for an appropriate instance
    uint32_t boardTag = ((board_id.vendor << 16) | board_id.device);
    map<uint32_t, Creator*> &factoryMap(getFactoryMap());
    map<uint32_t, Creator*>::iterator findIter = factoryMap.find(boardTag);
    if(findIter != factoryMap.end()) {
      retInstance = findIter->second->createInstance(nodeName, nodeHandle);
    } else {
      cout << "Unable to locate board abstraction class for vendor 0x"
           << setfill('0') << setw(4) << hex 
           << board_id.vendor
           << ", product 0x" << board_id.device
           << dec << endl;
    }
  }

  // Return the instance, or NULL if a failure occured
  return(retInstance);
}

map<uint32_t, XilinxFpcDevice::Creator*>& XilinxFpcDevice::getFactoryMap(void) {
  static map<uint32_t, Creator*> factoryMap;

  // Return the static instance, which is implicitly created upon the
  // first invocation of the method
  return(factoryMap);
}

// Protected type implementations

// Class XilinxFpcDevice::Creator

// Public interface

XilinxFpcDevice::Creator::Creator(uint16_t boardVendor, uint16_t boardDevice) {
  // Register the instance as the creator for the passed board info
  uint32_t boardTag = ((boardVendor << 16) | boardDevice);
  XilinxFpcDevice::getFactoryMap().insert(make_pair(boardTag, this));
}

XilinxFpcDevice::Creator::~Creator(void) {
}
