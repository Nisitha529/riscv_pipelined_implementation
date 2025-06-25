`timescale 1ns/1ps

module tb_regfile;

  reg         clk;
  reg         we3;
  reg  [4:0]  a1, a2, a3;
  reg  [31:0] wd3;
  wire [31:0] rd1, rd2;

  regfile dut (
    .clk  (clk),
    .we3  (we3),
    .a1   (a1),
    .a2   (a2),
    .a3   (a3),
    .wd3  (wd3),
    .rd1  (rd1),
    .rd2  (rd2)
  );

  task check(
    input [127:0] label,
    input [31:0]  expected1,
    input [31:0]  expected2
  );
  begin
    #1;
    $display("[%0t] %-15s | RD1: %08x (exp: %08x) | RD2: %08x (exp: %08x) | %s",
             $time, label, rd1, expected1, rd2, expected2,
             ((rd1 === expected1) && (rd2 === expected2)) ? "PASS" : "FAIL");
  end
  endtask

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Running regfile test...\n");

    we3 = 0;
    a1  = 0; a2 = 0; a3 = 0; wd3 = 0;
    #12;

    // Test 1: Write to x5 = 0xA5A5A5A5
    we3 = 1; a3 = 5; wd3 = 32'hA5A5A5A5;
    #5; clk = 0; #5; clk = 1;  // Negative edge write

    // Test 2: Read x5 -> should return 0xA5A5A5A5
    we3 = 0; a1 = 5; a2 = 5;
    #10; check("Read x5", 32'hA5A5A5A5, 32'hA5A5A5A5);

    // Test 3: Write to x0 (should be ignored)
    we3 = 1; a3 = 0; wd3 = 32'hFFFFFFFF;
    #5; clk = 0; #5; clk = 1;

    // Test 4: Read x0 (must be zero)
    we3 = 0; a1 = 0; a2 = 0;
    #10; check("Read x0", 32'h00000000, 32'h00000000);

    // Test 5: Write x10 = 0x12345678, Read x5 and x10
    we3 = 1; a3 = 10; wd3 = 32'h12345678;
    #5; clk = 0; #5; clk = 1;

    we3 = 0; a1 = 5; a2 = 10;
    #10; check("Read x5/x10", 32'hA5A5A5A5, 32'h12345678);

    $display("\nTest complete.");
    $finish;
  end

endmodule
