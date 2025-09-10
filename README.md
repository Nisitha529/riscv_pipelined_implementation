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

---

## Hazard Handling

- **Data hazards** (RAW):
  - Handled using forwarding/bypassing paths
  - Load-use hazards resolved by automatic stalls when necessary.
- **Control hazards**:
  - Basic flush or stall logic on branch/jump instructions in ID/EX

---

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
