`timescale 1ns/1ps

module tb_if_id;

  reg         clk;
  reg         reset;
  reg         clear;
  reg         enable;
  reg  [31:0] instrf;
  reg  [31:0] pcf;
  reg  [31:0] pcplus4f;

  wire [31:0] instrd;
  wire [31:0] pcd;
  wire [31:0] pcplus4d;

  if_id dut (
    .clk        (clk),
    .reset      (reset),
    .clear      (clear),
    .enable     (enable),
    .instrf     (instrf),
    .pcf        (pcf),
    .pcplus4f   (pcplus4f),
    .instrd     (instrd),
    .pcd        (pcd),
    .pcplus4d   (pcplus4d)
  );

  task check_outputs;
    input [127:0] label;
    input [31:0] expected_instrd;
    input [31:0] expected_pcd;
    input [31:0] expected_pcplus4d;
  begin
    #1;
    $display("[%0t] %-16s | InstrD: %08x | PCD: %08x | PCPlus4D: %08x | %s",
             $time, label,
             instrd, pcd, pcplus4d,
             ((instrd === expected_instrd) &&
              (pcd    === expected_pcd) &&
              (pcplus4d === expected_pcplus4d)) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Running IF_ID pipeline register test...\n");

    reset = 1; clear = 0; enable = 0;
    instrf = 0; pcf = 0; pcplus4f = 0;
    #12 reset = 0;

    // Test 1: Normal operation
    #3; enable = 1; clear = 0;
        instrf = 32'h12345678;
        pcf    = 32'h00000010;
        pcplus4f = 32'h00000014;
    #10;
    check_outputs("Normal Write", 32'h12345678, 32'h00000010, 32'h00000014);

    // Test 2: Clear = 1
    #3; clear = 1;
    #10;
    check_outputs("Clear Active", 32'h00000000, 32'h00000000, 32'h00000000);

    // Test 3: Enable = 0 (Hold previous)
    #3; clear = 0; enable = 0;
        instrf = 32'hFFFFFFFF;
        pcf    = 32'h11111111;
        pcplus4f = 32'h22222222;
    #10;
    check_outputs("Disabled Hold", 32'h00000000, 32'h00000000, 32'h00000000);

    // Test 4: Reset = 1
    #5; reset = 1;
    #5;
    check_outputs("Reset Active", 32'h00000000, 32'h00000000, 32'h00000000);

    $display("\nTest complete.");
    $finish;
  end

endmodule
