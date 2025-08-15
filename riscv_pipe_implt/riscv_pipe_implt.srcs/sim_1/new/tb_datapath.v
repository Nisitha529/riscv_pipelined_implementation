`timescale 1ns/1ps

module tb_datapath;

  // Clock and reset
  reg clk;
  reg reset;

  // DUT I/O
  wire [31:0] pcf;
  reg  [31:0] instrf;
  wire [31:0] instrd;
  wire [31:0] aluresultm;
  wire [31:0] writedatam;
  reg  [31:0] readdatam;

  // Control signals (set some default for simplicity)
  reg [1:0] resultsrcw = 2'd0;
  reg       pcjalsrce = 1'b0;
  reg       pcsrce    = 1'b0;
  reg       alusrcae  = 1'b0;
  reg [1:0] alusrcbe  = 2'd0;
  reg       regwritew = 1'b1;
  reg [2:0] immsrcd   = 3'd0;
  reg [3:0] alucontrole = 4'd0;
  reg [1:0] forwardae = 2'd0;
  reg [1:0] forwardbe = 2'd0;
  reg       stalld    = 1'b0;
  reg       stallf    = 1'b0;
  reg       flushd    = 1'b0;
  reg       flushe    = 1'b0;

  // Outputs from datapath to monitor
  wire zeroe, signe;
  wire [4:0] rs1d, rs2d, rs1e, rs2e, rde, rdm, rdw;

  // Instantiate DUT
  datapath dut (
    .clk         (clk),
    .reset       (reset),
    .resultsrcw  (resultsrcw),
    .pcjalsrce   (pcjalsrce),
    .pcsrce      (pcsrce),
    .alusrcae    (alusrcae),
    .alusrcbe    (alusrcbe),
    .regwritew   (regwritew),
    .immsrcd     (immsrcd),
    .alucontrole (alucontrole),
    .zeroe       (zeroe),
    .signe       (signe),
    .pcf         (pcf),
    .instrf      (instrf),
    .instrd      (instrd),
    .aluresultm  (aluresultm),
    .writedatam  (writedatam),
    .readdatam   (readdatam),
    .forwardae   (forwardae),
    .forwardbe   (forwardbe),
    .rs1d        (rs1d),
    .rs2d        (rs2d),
    .rs1e        (rs1e),
    .rs2e        (rs2e),
    .rde         (rde),
    .rdm         (rdm),
    .rdw         (rdw),
    .stalld      (stalld),
    .stallf      (stallf),
    .flushd      (flushd),
    .flushe      (flushe)
  );

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Simple test program (instructions)
  reg [31:0] test_program [0:15];
  integer i;

  initial begin
    // Example RISC-V instructions (addi and add)
    test_program[0] = 32'h00f00093;  // ADDI x1, x0, 15
    test_program[1] = 32'h01000113;  // ADDI x2, x0, 16
    test_program[2] = 32'h002081b3;  // ADD x3, x1, x2  (x3 = 31)
    // Fill rest with NOPs (ADDI x0, x0, 0)
    for (i = 3; i < 16; i = i + 1) test_program[i] = 32'h00000013;
  end

  integer cycle_count;
  integer error_count;
  reg stop_sim;

  // Feed instructions based on PC (word address)
  always @(posedge clk) begin
    if (!reset) begin
      if (pcf[31:2] < 16)
        instrf <= test_program[pcf[31:2]];
      else
        instrf <= 32'h00000013;  // NOP
    end else begin
      instrf <= 32'h00000013;  // NOP during reset
    end
  end

  initial begin
    // Initialize
    reset = 1;
    instrf = 0;
    cycle_count = 0;
    error_count = 0;
    stop_sim = 0;

    $dumpfile("datapath_tb.vcd");
    $dumpvars(0, tb_datapath);

    // Release reset after 20 ns
    #20 reset = 0;

    // Configure ALU control for ADD (for simplicity)
    // 4'b0000 assumed ADD in your alu module - adjust if different
    alucontrole = 4'b0000;
    alusrcae = 1'b0;
    alusrcbe = 2'b00;

    // Run simulation loop
    while (!stop_sim && cycle_count < 200) begin
      @(posedge clk);
      cycle_count = cycle_count + 1;

      // Simple check: After instruction 2 executes (ADD), aluresultm should be 31
      if (pcf == 8 && instrd == 32'h002081b3) begin
        if (aluresultm !== 32'd31) begin
          $error("Cycle %0d: ALU result mismatch. Got %0d, expected 31", cycle_count, aluresultm);
          error_count = error_count + 1;
          stop_sim = 1;
        end else begin
          $display("Cycle %0d: ALU result correct for ADD instruction", cycle_count);
        end
      end
    end

    if (!stop_sim)
      $display("Simulation ended after %0d cycles without errors.", cycle_count);

    $display("Test finished. Total errors: %0d", error_count);

    $finish;
  end

endmodule
