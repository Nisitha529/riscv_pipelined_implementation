`timescale 1ns/1ps

module tb_aludec;

  reg  [0:0]  opb5;
  reg  [2:0]  funct3;
  reg  [0:0]  funct7b5;
  reg  [1:0]  aluop;
  wire [3:0]  alucontrol;

  reg  [3:0]  expected;

  aludec dut (
    .opb5       (opb5),
    .funct3     (funct3),
    .funct7b5   (funct7b5),
    .aluop      (aluop),
    .alucontrol (alucontrol)
  );

  task run_test(
    input [1:0] aluop_in,
    input [2:0] funct3_in,
    input       funct7b5_in,
    input       opb5_in,
    input [3:0] expected_val,
    input [127:0] desc
  );
  begin
    aluop     = aluop_in;
    funct3    = funct3_in;
    funct7b5  = funct7b5_in;
    opb5      = opb5_in;
    expected  = expected_val;

    #5; // wait for logic to settle
    if (alucontrol === expected)
      $display("[PASS] %-20s | alucontrol = %b", desc, alucontrol);
    else
      $display("[FAIL] %-20s | expected = %b, got = %b", desc, expected, alucontrol);
  end
  endtask

  initial begin
    $display("Starting ALU Decoder Testbench...\n");

    run_test(2'b00, 3'b000, 1'b0, 1'b0, 4'b0000, "Load/Store     ");
    run_test(2'b01, 3'b000, 1'b0, 1'b0, 4'b0001, "Branch/Sub     ");
    run_test(2'b10, 3'b000, 1'b0, 1'b1, 4'b0000, "R-Type ADD     ");
    run_test(2'b10, 3'b000, 1'b1, 1'b1, 4'b0001, "R-Type SUB     ");
    run_test(2'b10, 3'b001, 1'b0, 1'b1, 4'b0100, "SLL/SLLI       ");
    run_test(2'b10, 3'b010, 1'b0, 1'b1, 4'b0101, "SLT/SLTI       ");
    run_test(2'b10, 3'b011, 1'b0, 1'b1, 4'b1000, "SLTU/SLTIU     ");
    run_test(2'b10, 3'b100, 1'b0, 1'b1, 4'b0110, "XOR/XORI       ");
    run_test(2'b10, 3'b101, 1'b0, 1'b1, 4'b0111, "SRL            ");
    run_test(2'b10, 3'b101, 1'b1, 1'b1, 4'b1111, "SRA            ");
    run_test(2'b10, 3'b110, 1'b0, 1'b1, 4'b0011, "OR/ORI         ");
    run_test(2'b10, 3'b111, 1'b0, 1'b1, 4'b0010, "AND/ANDI       ");
    run_test(2'b10, 3'b111, 1'b0, 1'b0, 4'b0010, "AND/ANDI no opb5");

    $display("\nAll tests completed.");
    $finish;
  end

endmodule
