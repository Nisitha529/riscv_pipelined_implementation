`timescale 1ns/1ps

module tb_maindec;

  reg  [6:0]  op;
  wire        regwrite;
  wire [1:0]  resultsrc;
  wire        memwrite;
  wire        branch;
  wire        alusrca;
  wire [1:0]  alusrcb;
  wire        jump;
  wire [2:0]  immsrc;
  wire [1:0]  aluop;

  maindec dut (
    .op         (op),
    .regwrite   (regwrite),
    .resultsrc  (resultsrc),
    .memwrite   (memwrite),
    .branch     (branch),
    .alusrca    (alusrca),
    .alusrcb    (alusrcb),
    .jump       (jump),
    .immsrc     (immsrc),
    .aluop      (aluop)
  );

  task run_test(
    input [6:0] opcode,
    input        exp_regwrite,
    input [2:0]  exp_immsrc,
    input        exp_alusrca,
    input [1:0]  exp_alusrcb,
    input        exp_memwrite,
    input [1:0]  exp_resultsrc,
    input        exp_branch,
    input [1:0]  exp_aluop,
    input        exp_jump,
    input [127:0] label
  );
    begin
      op = opcode;
      #5;

      $display("[%0t] %-15s", $time, label);
      $display("  Signal        | Expected | Actual  | Result");
      $display("  --------------+----------+---------+--------");
      $display("  regwrite      |    %b     |    %b    |  %s", exp_regwrite, regwrite,   (regwrite   === exp_regwrite)   ? "PASS" : "FAIL");
      $display("  immsrc        |   %03b    |   %03b   |  %s", exp_immsrc,   immsrc,     (immsrc     === exp_immsrc)     ? "PASS" : "FAIL");
      $display("  alusrca       |    %b     |    %b    |  %s", exp_alusrca,  alusrca,    (alusrca    === exp_alusrca)    ? "PASS" : "FAIL");
      $display("  alusrcb       |   %02b     |   %02b   |  %s", exp_alusrcb, alusrcb,    (alusrcb    === exp_alusrcb)    ? "PASS" : "FAIL");
      $display("  memwrite      |    %b     |    %b    |  %s", exp_memwrite, memwrite,  (memwrite   === exp_memwrite)   ? "PASS" : "FAIL");
      $display("  resultsrc     |   %02b     |   %02b   |  %s", exp_resultsrc,resultsrc,(resultsrc  === exp_resultsrc)  ? "PASS" : "FAIL");
      $display("  branch        |    %b     |    %b    |  %s", exp_branch,   branch,    (branch     === exp_branch)     ? "PASS" : "FAIL");
      $display("  aluop         |   %02b     |   %02b   |  %s", exp_aluop,   aluop,     (aluop      === exp_aluop)      ? "PASS" : "FAIL");
      $display("  jump          |    %b     |    %b    |  %s", exp_jump,     jump,      (jump       === exp_jump)       ? "PASS" : "FAIL");
      $display("");
    end
  endtask

  initial begin
    $display("Running maindec Testbench...\n");

    run_test(7'b0000011, 1, 3'b000, 0, 2'b01, 0, 2'b01, 0, 2'b00, 0, "LW");
    run_test(7'b0100011, 0, 3'b001, 0, 2'b01, 1, 2'b00, 0, 2'b00, 0, "SW");
    run_test(7'b0110011, 1, 3'b000, 0, 2'b00, 0, 2'b00, 0, 2'b10, 0, "R-Type");
    run_test(7'b1100011, 0, 3'b010, 0, 2'b00, 0, 2'b00, 1, 2'b01, 0, "B-Type");
    run_test(7'b0010011, 1, 3'b000, 0, 2'b01, 0, 2'b00, 0, 2'b10, 0, "I-Type");
    run_test(7'b1101111, 1, 3'b011, 0, 2'b00, 0, 2'b10, 0, 2'b00, 1, "JAL");
    run_test(7'b0010111, 1, 3'b100, 1, 2'b10, 0, 2'b00, 0, 2'b00, 0, "AUIPC");
    run_test(7'b0110111, 1, 3'b100, 1, 2'b01, 0, 2'b00, 0, 2'b00, 0, "LUI");
    run_test(7'b1100111, 1, 3'b000, 0, 2'b01, 0, 2'b10, 0, 2'b00, 1, "JALR");
    run_test(7'b0000000, 0, 3'b000, 0, 2'b00, 0, 2'b00, 0, 2'b00, 0, "NOP/RESET");

    $display("Testbench complete.");
    $finish;
  end

endmodule
