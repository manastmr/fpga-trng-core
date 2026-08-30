# FPGA True Random Number Generator (TRNG) Core with On-Chip Diagnostics

## Overview

This repository contains a lightweight, fully synthesizable Verilog-2001 True Random Number Generator (TRNG) IP core, designed for deployment on AMD/Xilinx FPGAs.

The core utilizes a multi-stage Ring Oscillator (RO) bank as a physical entropy source, exploiting semiconductor phase jitter. The raw, biased entropy stream is safely sampled, conditioned via a mathematical Von Neumann Extractor to achieve a balanced 50/50 bit ratio, and formatted into a 32-bit parallel random word.

A unique feature of this design is the integrated Real-Time Statistical Verification engine, which provides continuous on-chip health monitoring of the entropy quality through diagnostic counters.

## Architecture

The TRNG architecture is composed of a strictly pipelined hierarchy:

`trng_top.v` (Top-Level Integration)
1.  **Entropy Source:** `ro_bank.v` (XOR-linked combinatorial Ring Oscillators).
2.  **Sampling & CDC:** `ro_sampler.v` (2-stage synchronizer / metastability filter).
3.  **Conditioning:** `von_neumann_extractor.v` (Removes silicon bias via pair filtering).
4.  **Formatting:** `shift_register_32bit.v` (Serial-to-parallel conversion with handshaking).
5.  **Analytics:** `bit_statistics.v` (On-chip statistical diagnostics: Ones/Zeros ratio, Run tracking).

*(Refer to the system architecture diagram provided with this report for a visual representation.)*

## Key Features

*   **Physical Jitter Entropy:** Exploits intrinsic FPGA hardware noise; no pre-computation.
*   **Bias Correction:** Guarantees uniform 50% probability distribution using the mathematically proven Von Neumann method.
*   **32-Bit Output Handshaking:** Outputs are presented as full 32-bit words qualified by a one-cycle `word_valid` pulse for seamless integration with CPU buses (e.g., AXI).
*   **Integrated Diagnostics:** Provides five simultaneous 32-bit hardware diagnostic counters (`total_bits`, `ones`, `zeros`, `runs`, `longest_run`) for real-time monitoring.
*   **Metastability Immune:** Includes necessary clock domain crossing (CDC) logic to prevent metastability between the asynchronous ROs and the system clock.
*   **Ultra-Lean Footprint:** Optimized for minimal resource consumption.

## Synthesis Metrics (Xilinx 7-Series)

The design was synthesized targeting Xilinx 7-Series FPGAs. Note the small footprint despite full parallel diagnostic buses.

| Resource | Utilization Count | Available | Utilization % |
| :--- | :--- | :--- | :--- |
| **Slice LUTs** | **57** | 41,000 | < 0.2% |
| **Slice Registers (FFs)** | **268** | 82,000 | < 0.4% |
| **BUFGCTRL** | **1** | 32 | 3.1% |
| **Bonded IOBs** | **196** (6x32-bit diagnostics + cntrl) | 300 | 65.3% |

*(Note on IOB Count: The high pin count of 196 reflects exposing all six 32-bit hardware analytical buses for verification. In a deployed System-on-Chip (SoC) context, these diagnostics are typically routed internally to an AXI bridge and do not consume physical pins.)*

## Verification & Simulation

The design was verified through behavioral simulation using Xilinx Vivado.

### Fault-Model Verification: `extractor_tb.v`

A robust test scenario was executed to prove the extractor's capability. We intentionally generated and injected a completely broken, **~76% biased fault stream** (where bits were '1' 76% of the time).

**Expected (and Verified) Outcome:**
The `von_neumann_extractor.v` successfully processed the fault stream, discarded over 80% of the matching data pairs (`00` and `11`), and flattened the output distribution down to a perfect **~50.0% / ~50.0% split** across all valid bits counted. This verifies that the math behind the bias correction is working correctly in hardware.

## Running the Project

### System Requirements
*   Xilinx Vivado Design Suite (any recent version supporting 7-Series).

### Run Synthesis
1.  Open Vivado and create a new RTL project.
2.  Add all Verilog source files from the `rtl/` directory.
3.  Add the testbench files from the `tb/` directory as simulation sources.
4.  Set `trng_top.v` as your **Top Module**.
5.  Run **Synthesis** under the Flow Navigator. Open the synthesized design and access **Project Summary $\rightarrow$ Utilization** to inspect resource counts.

*(Note on Synthesis Warnings: Expect and ignore warnings regarding combinatorial loops within `ro_bank.v`—this is the intended behavior required to generate unclocked entropy.)*

### Run Simulation
1.  Set either `extractor_tb.v` or `trng_top_tb.v` as your Top simulation module.
2.  Run **Behavioral Simulation** under the Flow Navigator.
3.  Check the **Tcl Console** for a detailed text printout of the statistical results summarizing the total bits, ones/zeros count, and total run metrics after thousands of generated bits.
