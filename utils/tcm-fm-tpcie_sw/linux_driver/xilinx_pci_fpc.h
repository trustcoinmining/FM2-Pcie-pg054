/* xilinx_pci_fpc.h: Header file for the PCIe FPC driver */

#ifndef _XILINX_PCI_FPC_H_
#define _XILINX_PCI_FPC_H_

#include <linux/ioctl.h>

/* I/O control definitions */

#define FPC_IOC_CHAR 'f'

struct fpc_board_id {
  uint16_t vendor;
  uint16_t device;
};

#define IOC_GET_BOARD_ID  _IOR(FPC_IOC_CHAR, 0x01, struct fpc_board_id*)

/* TODO - Redefine with _IOW and a uint32_t num_blocks */
#define IOC_INIT_CONFIG _IOW(FPC_IOC_CHAR, 0x02, uint32_t)

/* Maximum size for a block of configuration bitstream data */
#define MAX_CONFIG_BLOCK_SIZE (1024)

/* Convenience constant for bytes per word (as defined by the driver) */
#define FPC_BYTES_PER_WORD  (sizeof(uint32_t))

/* Structure definition to carry blocks of configuration bitstream data */
struct fpc_data_block {
  uint32_t num_words;
  uint32_t block_words[MAX_CONFIG_BLOCK_SIZE];
};

#define IOC_CONFIG_BLOCK  _IOW(FPC_IOC_CHAR, 0x03, struct fpc_data_block*)

#endif
