/*
 * File        : test_fpc.cpp
 * Description : Test application for the Xilinx Fast Partial Configuration
 *               abstraction layer.
 *
 * Copyright (c) 2012, Xilinx
 * All rights reserved
 */

// System headers
#include <iostream>
#include <stdint.h>
#include <sstream>
#include <string>
#include <sys/stat.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>
#include <vector>

// Project headers
#include "XilinxFpcDevice.h"
#include "DemoBoard.h"

// Namespace using directives
using std::cerr;
using std::cout;
using std::endl;
using std::list;
using std::string;
using std::stringstream;

// Error return codes
#define RET_SUCCESS    ( 0)
#define RET_BAD_PARAM  (-1)
#define RET_NO_PERMS   (-2)

/**
 * Class definition for the test application object
 */
class XilinxFpcTest {

  // Constructor / destructor
public:

  /**
   * Constructor
   */
  XilinxFpcTest(const string &appName) :
    appName(appName) {
  }

  /**
   * Destructor
   */
  ~XilinxFpcTest(void) {
  }

  // Public interface methods
public:

  /**
   * Main thread of control, runs the test application
   */
  virtual int32_t run(string binFileName) {
    int32_t retValue = RET_SUCCESS;

    cout << "Running Xilinx Fast Partial Configuration test application" << endl;

    // Ensure the application is being run with sufficient privilege
    if(geteuid() != 0) {
      cerr << "Application must be run with root permissions" << endl;
      return(RET_NO_PERMS);
    }

    // Obtain references to the PCIe cards using the FPC mechanism in the system.
    // Specifically, obtain a collection of objects for any reference boards
    // loaded with the FPC demonstration application.
    //
    // By following the DemoBoard class as an example, custom boards may be 
    // abstracted yet use the common FPC mechanism by way of inheritance.  Any
    // design-specific capabilities may be implemented atop the base XilinxFpcDevice
    // class.
    list<DemoBoard*> demoBoards;
    list<DemoBoard*>::iterator board;
    
    XilinxFpcDevice::findInstances(demoBoards);
    cout << "Located " << demoBoards.size() << " FPC board(s)" << endl;

    // For each 'board' found, have it configure itself appropriately.
    // This loads the design-specific partition with a bitstream, preparing it
    // for actual use.
    for(board=demoBoards.begin(); board != demoBoards.end(); board++) {
      (*board)->configure(binFileName);
    }

    cout << "Configuration completed" << endl;

    return(retValue);
  }

  // Private attributes
private:

  /**
   * Name of the application
   */
  const string appName;

};

// Constants governing the parsing of command-line parameters
#define PARAM_TOKEN_DELIMITER ('=')

static const bool splitParamString(const string &pairString,
                                   string &param,
                                   string &value) {
  bool returnValue(false);

  string::size_type splitPos = pairString.find_first_of(PARAM_TOKEN_DELIMITER);
  if((splitPos != string::npos) && (pairString.length() > (splitPos + 1))) {
    param = pairString.substr(0, splitPos);
    value = pairString.substr(splitPos + 1);
    returnValue = true;
  }

  return(returnValue);
}

int main(int argc, char* argv[]) {
  int returnValue = 0;
  const string appName(argv[0]);
  string binFileName = "";

  // Process command-line parameters
  string param;
  string value;
  for(uint32_t argIndex = 1; argIndex < argc; argIndex++) {
    // Split each param / value pair, checking for errors
    string pairString(argv[argIndex]);
    const bool goodParam = splitParamString(pairString, param, value);
    if(goodParam == false) {
      cerr << "Bad parameter format : \"" << pairString << "\"" << endl;
      returnValue = RET_BAD_PARAM;
      break;
    }

    // Good parameter, react appropriately
    if(param == "file") {
      binFileName = value;
    } else {
      cerr << "Unrecognized parameter \"" << pairString << "\"" << endl;
      returnValue = RET_BAD_PARAM;
      break;
    }
  }

  // Create an instance of the demo application and run it
  if(returnValue == RET_SUCCESS) {
    XilinxFpcTest fpcTest(appName);
    returnValue = fpcTest.run(binFileName);
  }

  // Return the exit status
  return(returnValue);
}
