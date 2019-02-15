/**
 * File        - DemoBoard.h
 * Description - Class abstracting the Xilinx FPGA reference board, configured
 *               to use Fast Partial Configuration in conjunction with a demo
 *               design to illustrate the driver and abstraction framework.
 *
 * Copyright (c) 2012, Xilinx
 * All rights reserved.
 */

#ifndef _DEMO_BOARD_H_
#define _DEMO_BOARD_H_

// Base class header
#include "XilinxFpcDevice.h"

class DemoBoard : public XilinxFpcDevice {

  // Virtual Destructor
 public:

  virtual ~DemoBoard(void);

  // Public overrides from class XilinxFpcDevice
 public:

  /**
   * Returns a descriptive name for the type of device
   *
   * @return The name for the device
   */
  virtual const std::string& getDeviceName(void) const;

  /**
   * Configures the reference board with its demo configuration image, illustrating
   * the use of the FPC mechanism.
   */
  virtual void configure(std::string binFileName);

  // Public attributes
 public:

  /**
   * Board description constant
   */
  const static std::string k_BoardDescription;

  // Private type declarations
 private:

  /**
   * Inner class used to implement a polymorphic creation mechanism
   */
  class DemoBoard_Creator : public Creator {

  public:

    /**
     * Constructor
     */
    DemoBoard_Creator(void);

    /**
     * Virtual destructor
     */
    virtual ~DemoBoard_Creator(void);

    /**
     * Polymorphically creates an object abstracting the passed device node.
     *
     * @param nodeName   - Device node name to be used for driver interaction
     * @param nodeHandle - File handle for the device node
     * @return             A pointer to the newly-created instance
     */
    virtual XilinxFpcDevice* createInstance(const std::string &nodeName, 
					    int32_t nodeHandle);
  };

  // Private constructor
 private:

  /**
   * Creates an instance abstracting a probed device identified by the
   * driver layer.
   *
   * @param nodeName   - Device node name to be used for driver interaction
   * @param nodeHandle - Already-opened device node file handle
   */
  DemoBoard(const std::string &nodeName, int32_t nodeHandle);

  // Private attributes
 private:

  /**
   * Constant used by the example design for Vendor ID (Xilinx)
   */
  static const uint16_t k_XilinxVendorId;

  /**
   * Constant used by the example for Device ID (Created during example design customization)
   */
  static const uint16_t k_DemoBoardDeviceId;

  /**
   * Constant filename for the demonstration bitstream which gets configured
   */
  static const std::string k_DemoBinFilename;

  /**
   * Creator instance for the factory creation pattern
   */
  static DemoBoard_Creator creationAgent;

};

#endif
