# RISC‑V 5‑Stage Pipelined Processor Implementation with UVM Verification

## Project Overview
This project implements a 5-stage pipelined RISC-V processor in Verilog HDL, supporting the RV32I base integer instruction set. The processor follows the pipeline architecture with full forwarding and hazard detection capabilities. Designed for both simulation and FPGA deployment, this implementation provides a modular, extensible foundation for RISC-V processor development with verification testbenches and UVM verification.

---

## Features

- **5‑stage pipeline** following standard RISC‑V structure:
  - IF → ID → EX → MA → WB
- **Instruction support**: R-type, I-type, S-type, B-type, J-type, U-type
- **Hazard handling**:
  - **Data hazards**: resolved via forwarding and load-use interlocks
  - **Control hazards**: basic handling for branches
- **Pipeline registers** between stages to propagate instructions and data.

---

## Pipeline Architecture

Hardware implementation of a 5‑stage pipelined RISC‑V RV32I processor, structured into the following stages:

1. **Instruction Fetch (IF)**  
2. **Instruction Decode & Register Fetch (ID)**  
3. **Execution (EX)**  
4. **Memory Access (MA)**  
5. **Write Back (WB)**  

## Architecture Overview

### Instruction Fetch (IF) Stage
Responsible for supplying the processor with instructions from memory using the program counter (PC). The stage increments PC by 4 for sequential execution or updates it with branch/jump targets when control flow changes. The IF stage outputs both the fetched instruction and current PC value to subsequent stages.

### Instruction Decode (ID) Stage
Interprets instruction fields and prepares operands for execution. This stage extracts opcode, function codes, and register indices, reads source registers from the register file, and sign-extends immediate values. It also generates control signals for downstream units and performs early hazard detection.

### Execute (EX) Stage
Performs arithmetic, logical, and comparison operations using the ALU. Handles operand selection through forwarding multiplexers, computes branch target addresses, and evaluates branch conditions. This stage resolves data hazards through forwarding paths and plays a crucial role in determining control flow.

### Memory Access (MEM) Stage
Interfaces with data memory for load/store operations. Reads or writes data at computed addresses and passes through ALU results for non-memory instructions. The stage handles memory alignment and assumes single-cycle access in the current implementation.

### Write Back (WB) Stage
Finalizes instruction execution by writing results back to the register file. Selects between ALU output and memory data using the MemToReg signal and writes to the destination register. This stage ensures data correctness for dependent instructions.

## Key Modules

### Core Processing Units
- pc_module.v: Program counter management with sequential and branch updates
- instruction_memory.v: ROM for instruction storage
- controller.v: Main control unit for instruction decoding
- regfile.v: 32-register file with dual read ports and single write port
- alu.v: Arithmetic Logic Unit supporting RISC-V operations
- dmem.v: Data memory for load/store operations

### Pipeline registers
- if_id.v: IF to ID stage interface registers
- id_ex.v: ID to EX stage interface registers
- ex_mem.v: EX to MEM stage interface registers
- mem_wb.v: MEM to WB stage interface registers

### Hazard detection and forwarding
- hazardunit.v: Detects data and control hazards, manages stalls and forwarding
- mux2.v, mux3.v, mux4.v: Multiplexers for operand selection and forwarding

### Support modules
- extend.v: Immediate value sign-extension unit
- flopr.v: Register with reset functionality
- flopenr.v: Register with enable and reset control

## Features
### Complete RV32I implementation
- Implements base integer instruction set including:
   - Arithmetic operations (ADD, SUB, AND, OR, XOR, SLT)
   - Immediate variants (ADDI, ANDI, ORI, XORI, SLTI)
   - Load/Store instructions (LW, SW)
   - Control flow instructions (BEQ, BNE, JAL)

### Hazard Handling

- **Data hazards** (RAW):
  - Handled using forwarding/bypassing paths
  - Load-use hazards resolved by automatic stalls when necessary.
- **Control hazards**:
  - Basic flush or stall logic on branch/jump instructions in ID/EX

---

<img width="1105" height="434" alt="Linter_layout" src="https://github.com/user-attachments/assets/5fc4cd4e-ca57-4959-9bf5-1e7b4f59fe61" />

## Verification
The implementation includes testbenches for:
- Module-level functionality verification
- Pipeline hazard handling tests
- Instruction set compliance checking
- End-to program execution validation

## UVM Verification

### Environment
This file contains the top-level UVM environment class that includes all verification components. It instantiates and connects the agent, scoreboard, coverage collector, and register abstraction layer (RAL) model. The environment manages the testbench hierarchy by creating components in the build phase and establishing communication channels between them during the connect phase. It also configures the RAL model with hardware paths for backdoor access to the DUT's registers and memory.

### Sequencer
A simple UVM sequencer that manages the flow of sequence items from test sequences to the driver. This component acts as a transaction scheduler, arbitrating between different sequences and ensuring that only one sequence item is active at a time. It provides the communication bridge between the test layer and the driver layer.

### Driver
The driver receives sequence items from the sequencer and converts them into pin-level signal transitions on the DUT interface. It operates in a continuous loop, fetching items from the sequencer and applying them to the virtual interface on appropriate clock edges. This component translates abstract transaction-level commands into concrete signal wiggles that the RISC-V processor can understand and execute.

### Testbench Top Module
The top-level SystemVerilog module that instantiates the DUT and connects it to the UVM testbench through a virtual interface. This file contains the clock generation logic, initial block that starts the UVM test, and configuration database setup for sharing the interface and HDL paths throughout the testbench. It also includes VCD dumping for waveform debugging.

###  RISC-V Package
A SystemVerilog package containing all RISC-V-specific constants and type definitions. It defines the standard RISC-V opcodes, function codes for arithmetic and branch operations, and an enumerated type for all supported instructions. This package serves as a centralized repository for instruction encoding information used throughout the testbench.

### Sequence Item
Defines the transaction class that represents a RISC-V instruction and its execution results. This class contains fields for instruction inputs, processor outputs, and auxiliary verification data. It includes constraints for valid instruction generation, utility functions for instruction decoding and immediate extension, and UVM automation macros for field operations. This is the fundamental data structure passed between all testbench components.

### Monitor
The monitor observes DUT signals through the virtual interface and converts them into sequence items. It samples signals on clock edges, packages them into transaction objects, and broadcasts these transactions to the scoreboard and coverage collector via analysis ports. This component acts as the testbench's eyes, capturing DUT behavior for verification.

### Sequences
A comprehensive collection of sequence classes that generate specific test patterns. This includes sequences for random instruction generation, reset scenarios, and targeted sequences for each instruction type (ADD, SUB, LW, SW, branches, jumps, etc.). Each sequence controls the constraints and order of transactions to create meaningful test scenarios, enabling both random and directed testing strategies.

### SystemVerilog Interface
Defines the communication interface between the testbench and the DUT. This interface bundles all signals (clock, reset, instruction inputs, processor outputs) into a single object that can be passed throughout the UVM testbench via the configuration database. It serves as the contract between the verification environment and the hardware design.

### Agent
The agent encapsulates the driver, sequencer, and monitor into a single reusable component. It manages the creation and connection of these sub-components, providing a standardized way to instantiate the stimulus generation and response collection logic. The agent can operate in either active mode (with driver and sequencer) or passive mode (monitor only).

### Coverage Collector
Implements functional coverage collection for the RISC-V processor. It defines covergroups for instruction types, instruction transitions, register usage, memory operations, and reset behavior. The coverage collector samples transactions from the monitor and tracks which scenarios have been tested, helping measure verification completeness and identify untested corner cases.

### Scoreboard
Acts as a golden reference model that predicts expected processor behavior and compares it against actual DUT outputs. It models the RISC-V pipeline stages, hazard detection logic (forwarding, stalls, flushes), and computes expected results for each instruction type. The scoreboard verifies register file updates, memory operations, and program counter behavior, providing pass/fail status for each executed instruction.

### Register Abstraction Layer (RAL) Model
Implements a UVM register model for the RISC-V processor's register file and data memory. This model provides abstract access to hardware registers and memory locations, enabling both frontdoor (bus-based) and backdoor (direct HDL access) operations. The RAL model is used by the scoreboard to read register values for operand retrieval and to track expected state changes, serving as a reference for the processor's architectural state.

<!--
## Performance

- Ideal **CPI = 1**, under pipeline conditions :contentReference.  
- Achieves instruction-level parallelism by overlapping stages
- No structural hazards due to separate resources per stage.

---

## Usage & Simulation

1. **Instantiate** the `top_pipeline` module in your testbench.  
2. **Drive inputs**:
   - `clk`, `reset`
   - Instruction memory loaded with RV32I binaries  
3. **Run simulation** 
4. **Monitor outputs**:
   - PC, register file contents, memory interface  
   - Insert test programs to verify hazard handling and correct execution
-->

