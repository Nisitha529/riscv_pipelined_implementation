`timescale 1ns/1ps

module tb_controller;

  reg         clk;
  reg         reset;
  reg  [6:0]  op;
  reg  [2:0]  funct3;
  reg         funct7b5;
  reg         zeroe;
  reg         signe;
  reg         flushe;

  wire        resultsrce0;
  wire [1:0]  resultsrcw;
  wire        memwritem;
  wire        pcjalsrce;
  wire        pcsrce;
  wire        alusrcae;
  wire [1:0]  alusrcbe;
  wire        regwritem;
  wire        regwritew;
  wire [2:0]  immsrcd;
  wire [3:0]  alucontrole;

  controller dut (
    .clk         (clk),
    .reset       (reset),
    .op          (op),
    .funct3      (funct3),
    .funct7b5    (funct7b5),
    .zeroe       (zeroe),
    .signe       (signe),
    .flushe      (flushe),
    .resultsrce0 (resultsrce0),
    .resultsrcw  (resultsrcw),
    .memwritem   (memwritem),
    .pcjalsrce   (pcjalsrce),
    .pcsrce      (pcsrce),
    .alusrcae    (alusrcae),
    .alusrcbe    (alusrcbe),
    .regwritem   (regwritem),
    .regwritew   (regwritew),
    .immsrcd     (immsrcd),
    .alucontrole (alucontrole)
  );

  task check_result(
    input [127:0] label,
    input         exp_regwritew,
    input         exp_memwritem,
    input [1:0]   exp_resultsrcw,
    input [3:0]   exp_alucontrole,
    input         exp_pcsrce,
    input         exp_pcjalsrce
  );
  begin
    $display("[%0t] %-15s", $time, label);
    $display("  Signal         | Expected | Received | Result");
    $display("  ---------------+----------+----------+--------");
    $display("  regwritew      |    %b     |    %b     |  %s", exp_regwritew, regwritew,   (regwritew   === exp_regwritew)   ? "PASS" : "FAIL");
    $display("  memwritem      |    %b     |    %b     |  %s", exp_memwritem, memwritem,   (memwritem   === exp_memwritem)   ? "PASS" : "FAIL");
    $display("  resultsrcw     |   %02b     |   %02b     |  %s", exp_resultsrcw, resultsrcw, (resultsrcw  === exp_resultsrcw)  ? "PASS" : "FAIL");
    $display("  alucontrole    |   %04b    |   %04b    |  %s", exp_alucontrole, alucontrole, (alucontrole === exp_alucontrole) ? "PASS" : "FAIL");
    $display("  pcsrce         |    %b     |    %b     |  %s", exp_pcsrce, pcsrce, (pcsrce === exp_pcsrce) ? "PASS" : "FAIL");
    $display("  pcjalsrce      |    %b     |    %b     |  %s", exp_pcjalsrce, pcjalsrce, (pcjalsrce === exp_pcjalsrce) ? "PASS" : "FAIL");
    $display("");
  end
  endtask

  task apply_op(
    input [6:0] opcode,
    input [2:0] f3,
    input       f7b5,
    input       zero,
    input       sign
  );
  begin
    op       = opcode;
    funct3   = f3;
    funct7b5 = f7b5;
    zeroe    = zero;
    signe    = sign;
    #5 clk = 1; #5 clk = 0;
    #5 clk = 1; #5 clk = 0;
    #5 clk = 1; #5 clk = 0;  // wait 2 cycles for pipeline propagation
  end
  endtask

  initial begin
    $display("Running pipelined controller test...\n");

    clk = 0;
    reset = 1;
    flushe = 0;

    op = 0; funct3 = 0; funct7b5 = 0; zeroe = 0; signe = 0;
    #5 clk = 1; #5 clk = 0;
    reset = 0;

    apply_op(7'b0000011, 3'b010, 0, 0, 0); // LW
    check_result("LW", 1, 0, 2'b01, 4'b0000, 0, 0);

    apply_op(7'b0100011, 3'b010, 0, 0, 0); // SW
    check_result("SW", 0, 1, 2'b00, 4'b0000, 0, 0);

    apply_op(7'b1100011, 3'b000, 0, 1, 0); // BEQ
    check_result("BEQ", 0, 0, 2'b00, 4'b0001, 1, 0);

    apply_op(7'b1101111, 3'b000, 0, 0, 0); // JAL
    check_result("JAL", 1, 0, 2'b10, 4'b0000, 1, 0);

    apply_op(7'b1100111, 3'b000, 0, 0, 0); // JALR
    check_result("JALR", 1, 0, 2'b10, 4'b0000, 1, 1);

    $display("Controller test complete.");
    $finish;
  end

endmodule
