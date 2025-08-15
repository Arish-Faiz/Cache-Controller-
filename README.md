# 🚀 Direct-Mapped Cache Controller in Verilog 

**Author:** Arish Faiz — M.Tech, IIT Bombay *(Integrated Circuit & Systems)*  
**Course/Project:** Self Project  

This repository contains the complete design and implementation of a direct-mapped L1 cache controller.  
The project covers the **entire VLSI flow** — from initial RTL design in Verilog and functional verification to the final **GDSII layout** generated using OpenLane.

---

## ✨ Key Features & Specifications

| Feature           | Details |
|-------------------|---------|
| **Architecture**  | Direct-Mapped Cache |
| **Policy**        | Write-Back with Write-Allocate |
| **Cache Size**    | 32 Bytes *(4 lines of 8-byte words)* |
| **Address Width** | 4 bits *(2-bit tag, 2-bit index)* |
| **Verification**  | Comprehensive testbench covering various hit/miss scenarios |

---

## 🖥 Physical Design (RTL-to-GDSII)

The Verilog RTL was synthesized and implemented using **OpenLane** with the **SkyWater 130nm PDK**.

**Key Metrics:**

| Metric                  | Value         |
|-------------------------|---------------|
| **Die Area**            | 76642 μm²     |
| **Total Power**         | 41.1 μW       |
| **Worst Negative Slack**| 0.00 ns       |

---

## 🛠 Technologies Used
- **RTL Design:** Verilog HDL  
- **Verification:** Verilog Testbench, ModelSim/Vivado Simulator  
- **Physical Design:** OpenLane, SkyWater 130nm PDK  

---

## 📷 Layout Preview  
![GDSII Layout](gds/my_chip_gds.png)  

---

## 📜 License  
This project is licensed under the MIT License — see the LICENSE file for details.

