`timescale 1ns/1ps

module tb_flopr;

  reg         clk;
  reg         reset;
  reg  [31:0] d;
  wire [31:0] q;

  flopr dut (
    .clk   (clk),
    .reset (reset),
    .d     (d),
    .q     (q)
  );

  task check_output(
    input [127:0] label,
    input [31:0]  expected
  );
  begin
    #1;
    $display("[%0t] %-15s | Expected: %08x | Actual: %08x | %s",
             $time, label, expected, q,
             (q === expected) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    $display("Running flopr test...\n");

    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    reset = 1; d = 32'h00000000;
    #12; reset = 0;

    // Test 1: Write A5A5A5A5 (setup before clock edge)
    #3; d = 32'hA5A5A5A5;  // Set at 15ns (clock low)
    #20;
    #7; check_output("Write A5A5", 32'hA5A5A5A5);  // Check at 22ns

    // Test 2: Overwrite with 12345678
    #8; d = 32'h12345678;  // Set at 30ns (clock low)
    #20;
    #7; check_output("Write 1234", 32'h12345678);  // Check at 37ns

    // Test 3: Hold value
    #8; d = 32'hFFFFFFFF;  // Set at 45ns (no effect since always writing)
    #20;
    #7; check_output("Write FFFF", 32'hFFFFFFFF);  // Check at 52ns

    // Test 4: Reset
    #10; reset = 1;  // Set reset at 62ns
    #10; check_output("Reset", 32'h00000000);  // Check at 72ns

    $display("\nTest complete.");
    $finish;
  end

endmodule
