`timescale 1ns / 1ps

module tb_mux4;

  reg  [31:0] d0, d1, d2, d3;
  reg  [1:0]  s;
  wire [31:0] y;

  mux4 dut (
    .d0 (d0),
    .d1 (d1),
    .d2 (d2),
    .d3 (d3),
    .s  (s),
    .y  (y)
  );

  task check_output(
    input [127:0] label,
    input [1:0]   sel,
    input [31:0]  exp
  );
  begin
    s = sel;
    #1;
    $display("[%0t] %-12s | s = %02b | Expected = %08x | Actual = %08x | %s",
             $time, label, sel, exp, y,
             (y === exp) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    $display("Running mux4 test...\n");

    d0 = 32'hAAAA0000;
    d1 = 32'hBBBB1111;
    d2 = 32'hCCCC2222;
    d3 = 32'hDDDD3333;

    check_output("Select d0", 2'b00, d0);
    check_output("Select d1", 2'b01, d1);
    check_output("Select d2", 2'b10, d2);
    check_output("Select d3", 2'b11, d3);

    $display("\nTest complete.");
    $finish;
  end

endmodule
