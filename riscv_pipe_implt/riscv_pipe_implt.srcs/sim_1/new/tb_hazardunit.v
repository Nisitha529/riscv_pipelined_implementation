`timescale 1ns/1ps

module tb_hazardunit;

  reg  [4:0] rs1d, rs2d, rs1e, rs2e, rde, rdm, rdw;
  reg        regwritem, regwritew, resultsrce0, pcsrce;
  wire [1:0] forwardae, forwardbe;
  wire       stalld, stallf, flushd, flushe;

  integer errors = 0;

  // Instantiate DUT
  hazardunit dut (
    .rs1d       (rs1d),
    .rs2d       (rs2d),
    .rs1e       (rs1e),
    .rs2e       (rs2e),
    .rde        (rde),
    .rdm        (rdm),
    .rdw        (rdw),
    .regwritem  (regwritem),
    .regwritew  (regwritew),
    .resultsrce0(resultsrce0),
    .pcsrce     (pcsrce),
    .forwardae  (forwardae),
    .forwardbe  (forwardbe),
    .stalld     (stalld),
    .stallf     (stallf),
    .flushd     (flushd),
    .flushe     (flushe)
  );

  // Task to check forwarding outputs
  task check_forwarding(input [1:0] expected_ae, input [1:0] expected_be);
    begin
      if (forwardae !== expected_ae) begin
        $error("ForwardAE mismatch: got %b, expected %b", forwardae, expected_ae);
        errors = errors + 1;
      end
      if (forwardbe !== expected_be) begin
        $error("ForwardBE mismatch: got %b, expected %b", forwardbe, expected_be);
        errors = errors + 1;
      end
    end
  endtask

  // Task to check stall and flush signals
  task check_stall_flush(input expected_stalld, input expected_stallf, input expected_flushd, input expected_flushe);
    begin
      if (stalld !== expected_stalld) begin
        $error("StallD mismatch: got %b, expected %b", stalld, expected_stalld);
        errors = errors + 1;
      end
      if (stallf !== expected_stallf) begin
        $error("StallF mismatch: got %b, expected %b", stallf, expected_stallf);
        errors = errors + 1;
      end
      if (flushd !== expected_flushd) begin
        $error("FlushD mismatch: got %b, expected %b", flushd, expected_flushd);
        errors = errors + 1;
      end
      if (flushe !== expected_flushe) begin
        $error("FlushE mismatch: got %b, expected %b", flushe, expected_flushe);
        errors = errors + 1;
      end
    end
  endtask

  initial begin
    // Test 1: No forwarding, no stall, no flush
    rs1d = 5'd1; rs2d = 5'd2; rs1e = 5'd3; rs2e = 5'd4;
    rde = 5'd0; rdm = 5'd0; rdw = 5'd0;
    regwritem = 0; regwritew = 0; resultsrce0 = 0; pcsrce = 0;
    #1;
    check_forwarding(2'b00, 2'b00);
    check_stall_flush(0,0,0,0);

    // Test 2: ForwardAE from MEM stage (rs1e == rdm)
    rs1e = 5'd5; rdm = 5'd5; regwritem = 1;
    #1;
    check_forwarding(2'b10, 2'b00);

    // Test 3: ForwardAE from WB stage (rs1e == rdw)
    regwritem = 0; 
    regwritew = 1; 
    rdw = 5'd6; 
    rs1e = 5'd6;
    #1;
    check_forwarding(2'b01, 2'b00);

    // Test 4: ForwardBE from MEM stage (rs2e == rdm)
    regwritem = 1; regwritew = 0; rs2e = 5'd7; rdm = 5'd7;
    #1;
    check_forwarding(2'b01, 2'b10); // forwardae was last set to 01, need to reset
    // Reset forwardae to 00 for this test
    rs1e = 5'd0; regwritem = 1; regwritew = 0; #1;
    check_forwarding(2'b00, 2'b10);

    // Test 5: ForwardBE from WB stage (rs2e == rdw)
    regwritem = 0; regwritew = 1; rs2e = 5'd8; rdw = 5'd8;
    #1;
    check_forwarding(2'b00, 2'b01);

    // Test 6: Stall and flush due to lwstall
    rde = 5'd9; rs1d = 5'd9; rs2d = 5'd10; resultsrce0 = 1;
    pcsrce = 0;
    #1;
    check_stall_flush(1,1,0,1);
    check_forwarding(forwardae, forwardbe); // forwarding unchanged

    // Test 7: Stall and flush due to pcsrce
    pcsrce = 1; resultsrce0 = 0;
    #1;
    check_stall_flush(0,0,1,1);

    // Test 8: Stall and flush due to both lwstall and pcsrce
    pcsrce = 1; resultsrce0 = 1;
    rde = 5'd11; rs1d = 5'd12; rs2d = 5'd11;
    #1;
    check_stall_flush(1,1,1,1);

    if (errors == 0)
      $display("All hazardunit tests passed.");
    else
      $display("%0d errors detected in hazardunit tests.", errors);

    $finish;
  end

endmodule
