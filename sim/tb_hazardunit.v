`timescale 1ns/1ps

module tb_hazardunit;

  reg  [4:0] rs1d, rs2d, rs1e, rs2e;
  reg  [4:0] rde, rdm, rdw;
  reg        regwritem, regwritew;
  reg        resultsrce0, pcsrce;

  wire [1:0] forwardae;
  wire [1:0] forwardbe;
  wire       stalld;
  wire       stallf;
  wire       flushd;
  wire       flushe;

  hazardunit dut (
    .rs1d        (rs1d),
    .rs2d        (rs2d),
    .rs1e        (rs1e),
    .rs2e        (rs2e),
    .rde         (rde),
    .rdm         (rdm),
    .rdw         (rdw),
    .regwritem   (regwritem),
    .regwritew   (regwritew),
    .resultsrce0 (resultsrce0),
    .pcsrce      (pcsrce),
    .forwardae   (forwardae),
    .forwardbe   (forwardbe),
    .stalld      (stalld),
    .stallf      (stallf),
    .flushd      (flushd),
    .flushe      (flushe)
  );

  task check(
    input [127:0] label,
    input [1:0]   exp_fwdA,
    input [1:0]   exp_fwdB,
    input         exp_stallD,
    input         exp_stallF,
    input         exp_flushD,
    input         exp_flushE
  );
  begin
    #1;
    $display("[%0t] %s", $time, label);
    $display("  Signal       | Expected | Received | Result");
    $display("  -------------+----------+----------+--------");
    $display("  forwardae    |    %02b    |    %02b    |  %s", exp_fwdA, forwardae,  (forwardae  === exp_fwdA)   ? "PASS" : "FAIL");
    $display("  forwardbe    |    %02b    |    %02b    |  %s", exp_fwdB, forwardbe,  (forwardbe  === exp_fwdB)   ? "PASS" : "FAIL");
    $display("  stalld       |     %b     |     %b     |  %s",  exp_stallD, stalld,   (stalld     === exp_stallD)? "PASS" : "FAIL");
    $display("  stallf       |     %b     |     %b     |  %s",  exp_stallF, stallf,   (stallf     === exp_stallF)? "PASS" : "FAIL");
    $display("  flushd       |     %b     |     %b     |  %s",  exp_flushD, flushd,   (flushd     === exp_flushD)? "PASS" : "FAIL");
    $display("  flushe       |     %b     |     %b     |  %s",  exp_flushE, flushe,   (flushe     === exp_flushE)? "PASS" : "FAIL");
    $display("");
  end
  endtask

  initial begin
    $display("Running hazardunit test...\n");

    // Case 1: No hazards
    rs1e        = 5'd1;
    rs2e        = 5'd2;
    rdm         = 5'd0;
    rdw         = 5'd0;
    rs1d        = 5'd0;
    rs2d        = 5'd0;
    regwritem   = 0;
    regwritew   = 0;
    resultsrce0 = 0;
    pcsrce      = 0;
    rde         = 5'd0;
    #5;
    check("No Hazard", 2'b00, 2'b00, 0, 0, 0, 0);

    // Case 2: Forward from MEM to rs1e
    rs1e        = 5'd5;
    rdm         = 5'd5;
    regwritem   = 1;
    #5;
    check("Forward MEM->A", 2'b10, 2'b00, 0, 0, 0, 0);

    // Case 3: Forward from WB to rs2e
    rs2e        = 5'd6;
    rdw         = 5'd6;
    regwritew   = 1;
    #5;
    check("Forward WB->B", 2'b10, 2'b01, 0, 0, 0, 0);

    // Case 4: Load-Use Hazard
    rs1d        = 5'd7;
    rs2d        = 5'd0;
    rde         = 5'd7;
    resultsrce0 = 1;
    #5;
    check("Load-Use Hazard", 2'b10, 2'b01, 1, 1, 0, 1);

    // Case 5: Branch Taken
    pcsrce      = 1;
    resultsrce0 = 0;
    #5;
    check("Branch Taken", 2'b10, 2'b01, 0, 0, 1, 1);

    $display("Test complete.");
    $finish;
  end

endmodule
