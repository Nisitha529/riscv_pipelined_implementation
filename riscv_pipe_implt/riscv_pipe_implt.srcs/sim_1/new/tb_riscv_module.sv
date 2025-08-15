`timescale 1ns / 1ps

module riscv_module_tb;

  reg         clk;
  reg         reset;
  reg  [31:0] instrf;
  wire [31:0] pcf;
  wire        memwritem;
  wire [31:0] aluresultm;
  wire [31:0] writedatam;
  reg  [31:0] readdatam;

  // Instantiate the DUT
  riscv_module dut (
    .clk        (clk),
    .reset      (reset),
    .pcf        (pcf),
    .instrf     (instrf),
    .memwritem  (memwritem),
    .aluresultm (aluresultm),
    .writedatam (writedatam),
    .readdatam  (readdatam)
  );

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Simple program stored in an array (instruction memory)
  reg [31:0] program_mem [0:31];
  integer i;

  initial begin
    // Initialize program (simple instructions, replace with your own)
    program_mem[0]  = 32'h00f00093;  // ADDI x1, x0, 15
    program_mem[1]  = 32'h00100113;  // ADDI x2, x0, 1
    program_mem[2]  = 32'h002081b3;  // ADD x3, x1, x2
    program_mem[3]  = 32'h00310233;  // ADD x4, x2, x3
    program_mem[4]  = 32'h00000013;  // NOP (ADDI x0, x0, 0)
    program_mem[5]  = 32'h00000013;  // NOP
    program_mem[6]  = 32'h00000013;  // NOP
    program_mem[7]  = 32'h00000013;  // NOP
    // Fill remaining memory with NOPs
    for (i=8; i<32; i=i+1) program_mem[i] = 32'h00000013;
  end

  // Feed instruction based on PC (assuming PC is word addressable and aligned)
  always @(posedge clk) begin
    if (reset)
      instrf <= 32'h00000013;  // NOP during reset
    else if (pcf[31:2] < 32)
      instrf <= program_mem[pcf[31:2]];
    else
      instrf <= 32'h00000013;  // NOP if PC out of range
  end

  // Simple data memory model: read always zero for now
  always @(posedge clk) begin
    // For now, return zero on reads
    readdatam <= 32'h00000000;
  end

  // Reset logic
  initial begin
    reset = 1;
    #20;
    reset = 0;
  end

  // Monitor outputs
  initial begin
    $dumpfile("riscv_module_tb.vcd");
    $dumpvars(0, riscv_module_tb);

    $display("Time  PC       Instr     MemWrite Addr      WriteData ALUResult");
    $monitor("%0t  %h %h %b %h %h %h", 
              $time, pcf, instrf, memwritem, aluresultm, writedatam, aluresultm);

    // Run simulation for a fixed number of cycles
    #500;
    $display("Simulation finished");
    $finish;
  end

endmodule
