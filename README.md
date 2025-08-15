# Direct-Mapped Cache Controller in Verilog
This repository contains the complete design and implementation of a direct-mapped L1 cache controller. The project covers the entire VLSI flow, from initial RTL design in Verilog and functional verification, to the final GDSII layout generated using OpenLane.

---

## Key Features & Specifications

* Architecture: Direct-Mapped Cache
* Policy: Write-Back with Write-Allocate
* Cache Size: 32 Bytes (4 lines of 8-byte words)
* Address Width: 4 bits (2-bit tag, 2-bit index)
* Verification: Includes a comprehensive testbench covering various hit/miss scenarios.

---

## Physical Design (RTL-to-GDSII)

The Verilog RTL was successfully synthesized and implemented using the **OpenLane** automated flow with the **SkyWater 130nm** PDK.


---

## Technologies Used

* **RTL Design**: Verilog HDL
* **Verification**: Verilog Testbench, ModelSim/Vivado Simulator
* **Physical Design**: OpenLane, SkyWater 130nm PDK
