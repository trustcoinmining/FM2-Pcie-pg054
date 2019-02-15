# FM2 board tendom Prom and PCI-e prebuilt , base on pg054-7series-pcie.

PCI-e PROM and PCI-e Application Tutorial for FM2, port from Xilinx pg054 tutorial

## Here is PCI-e usage examples for FM2 board.

You can refer here. [pg054 Xilinx pdf](https://www.xilinx.com/support/documentation/ip_documentation/pcie_7x/v3_0/pg054-7series-pcie.pdf)

archive is pre-built (synthesized) vivado projects.

You can customize it from the `./pcie_7x_0_ex/import/pci_app_7x.v `

After bistream generation , we are providing the pci-e rescan scripts.

```
# pci-e rescan
$ sudo ./rescan2.sh

lspci | grep Xilinx 

01:00.0 Memory Conroller: Xilinx Corporation Device 7024
```

You can identify it.

Any feedback is welcome and we have a bounty program, share project application source for FM2L.

Thanks.
