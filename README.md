# I2C Master Controller Design

## 📌 Overview
This repository contains a fully functional **I2C Master Controller** implemented in **Verilog HDL**. The design handles start/stop conditions, address transmission, data read/write, and ACK/NACK generation following standard I2C protocol timing.

---

## 🛠️ Project Contents
* `i2c_master.v`: Verilog implementation of the I2C Master module (FSM & Open-Drain logic).
* `master_tb.v`: Testbench simulating master-slave interactions with Pull-up resistor setups.
* `Shimaa Ashraf I2C Master Controller.pdf`: Full technical documentation and design architecture report.

---

## 📊 Verification & Waveform Results
The simulation was verified using **ModelSim**, ensuring proper timing for Address Transmission (`7'h5A`), Data Phase (`8'hA5`), and Open-Drain ACK generation without any contention errors.
