# RISC‑V 5‑Stage Pipelined Processor Implementation

## Project Overview
This project implements a 5-stage pipelined RISC-V processor in Verilog HDL, supporting the RV32I base integer instruction set. The processor follows the pipeline architecture with full forwarding and hazard detection capabilities. Designed for both simulation and FPGA deployment, this implementation provides a modular, extensible foundation for RISC-V processor development with verification testbenches.

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

