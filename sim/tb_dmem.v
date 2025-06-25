`timescale 1ns/1ps

module tb_dmem;

  reg         clk;
  reg         we;
  reg  [31:0] a;
  reg  [31:0] wd;
  wire [31:0] rd;

  dmem dut (
    .clk (clk),
    .we  (we),
    .a   (a),
    .wd  (wd),
    .rd  (rd)
  );

  task display_check(
    input [31:0] expected,
    input [31:0] received,
    input [127:0] label
  );
  begin
    $display("[%0t] %s", $time, label);
    $display("  Expected = 0x%08x | Received = 0x%08x | %s\n",
              expected, received, (expected === received) ? "PASS" : "FAIL");
  end
  endtask

  // Clock generator
  always #5 clk = ~clk;

  initial begin
    $display("Running dmem testbench...\n");
    clk = 0;
    we  = 0;
    a   = 0;
    wd  = 0;

    // Write 0xDEADBEEF to address 0
    @(negedge clk);
    a  = 32'h0000_0000;
    wd = 32'hDEAD_BEEF;
    we = 1;
    @(negedge clk);
    we = 0;

    // Write 0xCAFEBABE to address 4
    @(negedge clk);
    a  = 32'h0000_0004;
    wd = 32'hCAFE_BABE;
    we = 1;
    @(negedge clk);
    we = 0;

    // Read address 0
    @(negedge clk);
    a = 32'h0000_0000;
    @(posedge clk);
    #1 display_check(32'hDEAD_BEEF, rd, "Reading address 0");

    // Read address 4
    @(negedge clk);
    a = 32'h0000_0004;
    @(posedge clk);
    #1 display_check(32'hCAFE_BABE, rd, "Reading address 4");

    // Read uninitialized address (should be X or 0 depending on simulator)
    @(negedge clk);
    a = 32'h0000_0008;
    @(posedge clk);
    #1 display_check(32'h0000_0000, rd, "Reading address 8 (default)");

    $display("\nTestbench complete.");
    $finish;
  end

endmodule
