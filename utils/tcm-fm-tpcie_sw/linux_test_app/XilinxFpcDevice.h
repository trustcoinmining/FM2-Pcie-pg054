/**
 * File        - XilinxFpcDevice.h
 * Description - Class abstracting instances of PCIe devices making use of
 *               the Fast Partial Configuration (FPC) mechanism.
 *
 *               This class interfaces to the POSIX device driver layer,
 *               abstracting the FPC services of a single detected PCIe device.
 *               It is intended to be subclassed by concrete PCIe design classes,
 *               which layer on design-specific services accessible through the
 *               device driver.
 *
 * Copyright (c) 2012, Xilinx
 * All rights reserved.
 */

#ifndef _XILINX_FPC_DEVICE_H_
#define _XILINX_FPC_DEVICE_H_

// STL headers
#include <list>
#include <map>
#include <string>

// Standard library headers
#include <stdint.h>

class XilinxFpcDevice {

  // Virtual Destructor
 public:

  virtual ~XilinxFpcDevice(void);

  // Public abstract interface
 public:

  /**
   * Returns a descriptive name for the type of device
   *
   * @return The name for the device
   */
  virtual const std::string& getDeviceName(void) const = 0;

  /**
   * Configures the device with its final configuration image, using the partial
   * configuration facilities hosted over PCIe.
   */
  virtual void configure(std::string binFileName) = 0;

  // Public interface methods
 public:

  /**
   * Returns a collection of all detected device instances
   */
  static std::list<XilinxFpcDevice*> getInstances(void);

  /**
   * Template method to return a collection of boards abstracted by a 
   * particular object class.
   */
  template <class BC> static void findInstances(std::list<BC*> &boardList) {
    
    // Clear the passed list, then obtain a list of all instances
    boardList.clear();
    std::list<XilinxFpcDevice*> baseList(getInstances());

    for(std::list<XilinxFpcDevice*>::iterator baseIter = baseList.begin();
        baseIter != baseList.end();
        ++baseIter) {
      // Use run-time type identification to filter out only instances of
      // the desired subclass
      BC *testPtr = dynamic_cast<BC*>(*baseIter);
      if(testPtr != NULL) boardList.push_back(testPtr);
    }
  }

  // Protected type declarations
 protected:

  /**
   * Inner class used to implement a polymorphic creation mechanism
   */
  class Creator {

    // Public interface
  public:

    /**
     * Constructor
     *
     * @param boardVendor - PCI vendor ID of the board this instance creates for
     * @param boardDevice - PCI device ID of the board this instance creates for
     */
    explicit Creator(uint16_t boardVendor, uint16_t boardDevice);

    /**
     * Virtual destructor
     */
    virtual ~Creator(void);

    /**
     * Polymorphically creates an object abstracting the passed device node.
     * The returned instance is a concrete subclass of XilinxFpcDevice, and
     * may layer on additional, board-specific functionality accessible via
     * its device driver.
     *
     * @param nodeName   - Device node name to be used for driver interaction
     * @param nodeHandle - File handle for the device node
     * @return             A pointer to the newly-created instance
     */
    virtual XilinxFpcDevice* createInstance(const std::string &nodeName, 
                                            int32_t nodeHandle) = 0;
  };

  // Protected constructor
 protected:

  /**
   * Creates an instance abstracting a probed device identified by the
   * driver layer.
   *
   * @param nodeName   - Device node name to be used for driver interaction
   * @param nodeHandle - Already-opened device node file handle
   */
  XilinxFpcDevice(const std::string &nodeName, int32_t nodeHandle);

  // Protected helper methods
 protected:

  /**
   * Configures the user partition of the device with the passed binary 
   * bitstream file.
   *
   * @param binFilename - Pathname of a binary bitstream file with which to configure
   *                      the user partition.  This must be a non-bit-reversed .bin file,
   *                      as generated with 'promgen -b -p bin'.
   */
  void configUserPartition(const std::string &binFilename);

  // Private helper methods
 private:

  /**
   * Creates and opens the device node for the instance
   */
  static const bool createNode(const std::string &devName, const std::string &nodeName);

  /**
   * Attempts to obtain an object instance to abstract the passed device node.
   *
   * @param  nodeName - The pathname of the device node to be abstracted
   * @return            A derived class instance capable of abstracting the device, or
   *                    NULL if no such class could be located.
   */
  static XilinxFpcDevice* abstractDevice(const std::string &nodeName);

  /**
   * Returns the associative map of board tags to creation devices, creating upon
   * first use.
   *
   * @return A reference to the factory creation map
   */
  static std::map<uint32_t, Creator*>& getFactoryMap(void);

  // Private attributes
 private:

  /**
   * Device node name
   */
  const std::string nodeName;

  /**
   * File handle from the opened device node
   */
  int32_t nodeHandle;

  /**
   * Root prefix for probed FPC devices
   */
  static const std::string FpcDeviceRootPrefix;

  /**
   * Root pathname for created misc device file nodes
   */
  static const std::string FpcDeviceNodeBase;

};

#endif
