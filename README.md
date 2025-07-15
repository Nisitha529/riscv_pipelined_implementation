# RISC‑V 5‑Stage Pipelined Processor (RV32I)

Hardware implementation of a 5‑stage pipelined RISC‑V RV32I processor, structured into the following stages:

1. **Instruction Fetch (IF)**  
2. **Instruction Decode & Register Fetch (ID)**  
3. **Execution (EX)**  
4. **Memory Access (MA)**  
5. **Write Back (WB)**  

Designed as a learning-oriented yet functional pipeline, this CPU supports all core RV32I instruction types and includes hazard mitigation logic.

---

## Features

- **5‑stage pipeline** following standard RISC‑V structure:
  - IF → ID → EX → MA → WB :contentReference[oaicite:1]{index=1}
- **Instruction support**: R-type, I-type, S-type, B-type, J-type, U-type
- **Hazard handling**:
  - **Data hazards**: resolved via forwarding and load-use interlocks
  - **Control hazards**: basic handling for branches
- **Pipeline registers** between stages to propagate instructions and data.

---

## Architecture Overview

- **IF stage**: fetches instruction from memory, updates PC (branch resolution in later stages)
- **ID stage**: decodes opcode, reads register file, sign-extends immediate values
- **EX stage**: ALU operations and branch target calculations
- **MA stage**: memory read/write for load/store instructions
- **WB stage**: writes results back into the register file

Intermediate registers (IF/ID, ID/EX, EX/MA, MA/WB) buffer pipeline state across cycles.

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
