`timescale 1ns/1ps

module tb_mux2;

  reg  [31:0] d0;
  reg  [31:0] d1;
  reg         s;
  wire [31:0] y;

  mux2 dut (
    .d0 (d0),
    .d1 (d1),
    .s  (s),
    .y  (y)
  );

  task check_output(
    input [127:0] label,
    input [31:0]  expected
  );
  begin
    #1;
    $display("[%0t] %-15s | Expected: %08x | Actual: %08x | %s",
             $time, label, expected, y,
             (y === expected) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    $display("Running mux2 test...\n");

    // Test 1: Select d0
    d0 = 32'hAAAAAAAA;
    d1 = 32'h55555555;
    s  = 0;
    #10;
    check_output("Select d0", 32'hAAAAAAAA);

    // Test 2: Select d1
    s = 1;
    #10;
    check_output("Select d1", 32'h55555555);

    // Test 3: Change inputs, select d0
    d0 = 32'h12345678;
    d1 = 32'h87654321;
    s  = 0;
    #10;
    check_output("New d0", 32'h12345678);

    // Test 4: Select new d1
    s = 1;
    #10;
    check_output("New d1", 32'h87654321);

    $display("\nTest complete.");
    $finish;
  end

endmodule
