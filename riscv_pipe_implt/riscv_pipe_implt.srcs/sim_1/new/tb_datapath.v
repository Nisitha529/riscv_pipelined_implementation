`timescale 1ns/1ps

module tb_datapath;

  reg         clk;
  reg         reset;
  reg  [1:0]  resultsrcw;
  reg         pcjalsrce;
  reg         pcsrce;
  reg         alusrcae;
  reg  [1:0]  alusrcbe;
  reg         regwritew;
  reg  [2:0]  immsrcd;
  reg  [3:0]  alucontrole;
  wire        zeroe;
  wire        signe;
  wire [31:0] pcf;
  reg  [31:0] instrf;
  wire [31:0] instrd;
  wire [31:0] alu_resultm, writedatam;
  reg  [31:0] readdatam;
  reg  [1:0]  forwardae, forwardbe;
  wire [4:0]  rs1d, rs2d, rs1e, rs2e;
  wire [4:0]  rde, rdm, rdw;
  reg         stalld, stallf, flushd, flushe;

  datapath dut (
    .clk           (clk),
    .reset         (reset),
    .resultsrcw    (resultsrcw),
    .pcjalsrce     (pcjalsrce),
    .pcsrce        (pcsrce),
    .alusrcae      (alusrcae),
    .alusrcbe      (alusrcbe),
    .regwritew     (regwritew),
    .immsrcd       (immsrcd),
    .alucontrole   (alucontrole),
    .zeroe         (zeroe),
    .signe         (signe),
    .pcf           (pcf),
    .instrf        (instrf),
    .instrd        (instrd),
    .aluresultm    (alu_resultm),
    .writedatam    (writedatam),
    .readdatam     (readdatam),
    .forwardae     (forwardae),
    .forwardbe     (forwardbe),
    .rs1d          (rs1d),
    .rs2d          (rs2d),
    .rs1e          (rs1e),
    .rs2e          (rs2e),
    .rde           (rde),
    .rdm           (rdm),
    .rdw           (rdw),
    .stalld        (stalld),
    .stallf        (stallf),
    .flushd        (flushd),
    .flushe        (flushe)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Running datapath test...\n");

    reset       = 1;
    instrf      = 32'b000000000011_00010_000_00001_0110011; // add x1, x2, x3
    resultsrcw  = 2'b00;
    pcjalsrce   = 0;
    pcsrce      = 0;
    alusrcae    = 0;
    alusrcbe    = 2'b00;
    regwritew   = 1;
    immsrcd     = 3'b000;
    alucontrole = 4'b0000; // ADD
    readdatam   = 32'h00000000;
    forwardae   = 2'b00;
    forwardbe   = 2'b00;
    stalld      = 0;
    stallf      = 0;
    flushd      = 0;
    flushe      = 0;

    #10;
    reset = 0;

    // Simulate 5 pipeline cycles
    repeat (10) @(posedge clk);

    // Check if ALU result is as expected (assuming x2=3, x3=4 from rf preload)
    $display("[Time %0t] ALUResultM = %h | Expected: %h | %s",
             $time, alu_resultm, 32'h00000007,
             (alu_resultm === 32'h00000007) ? "PASS" : "FAIL");

    $display("\nTest complete.");
    $finish;
  end

endmodule
