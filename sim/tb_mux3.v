`timescale 1ns / 1ps

module tb_mux3;

  reg  [31:0] d0;
  reg  [31:0] d1;
  reg  [31:0] d2;
  reg  [1:0]  s;
  wire [31:0] y;

  mux3 dut (
    .d0 (d0),
    .d1 (d1),
    .d2 (d2),
    .s  (s),
    .y  (y)
  );

  task check_output(
    input [127:0] label,
    input [1:0]   sel,
    input [31:0]  expected
  );
  begin
    #1;
    $display("[%0t] %-15s | s: %02b | Expected: %08x | Actual: %08x | %s",
             $time, label, sel, expected, y,
             (y === expected) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    $display("Running mux3 test...\n");

    d0 = 32'hAAAAAAAA;
    d1 = 32'hBBBBBBBB;
    d2 = 32'hCCCCCCCC;

    s = 2'b00;
    check_output("Select d0", s, 32'hAAAAAAAA);

    s = 2'b01;
    check_output("Select d1", s, 32'hBBBBBBBB);

    s = 2'b10;
    check_output("Select d2", s, 32'hCCCCCCCC);

    s = 2'b11;
    check_output("Select d2", s, 32'hCCCCCCCC);

    $display("\nTest complete.");
    $finish;
  end

endmodule
