obj-m = tcm_fm_pci_fpc_main.o
KVERSION = $(shell uname -r)
PWD = $(shell pwd)

all:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules
clean:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) clean

# all: xilinx_pci_fpc_main.o
