`timescale 1ns/1ps

module tb_c_im_iw;

  reg         clk;
  reg         reset;
  reg         regwritem;
  reg  [1:0]  resultsrcm;

  wire        regwritew;
  wire [1:0]  resultsrcw;

  c_im_iw dut (
    .clk        (clk),
    .reset      (reset),
    .regwritem  (regwritem),
    .resultsrcm (resultsrcm),
    .regwritew  (regwritew),
    .resultsrcw (resultsrcw)
  );

  task print_state(
    input [127:0] label,
    input         exp_regwrite,
    input [1:0]   exp_resultsrc
  );
  begin
    $display("[%0t] %-20s", $time, label);
    $display("         Signal        |  Expected  |  Received");
    $display("  ---------------------+------------+-----------");
    $display("  regwritew            |     %b      |     %b", exp_regwrite, regwritew);
    $display("  resultsrcw           |     %02b     |     %02b", exp_resultsrc, resultsrcw);
    $display("");
  end
  endtask

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $display("Running c_im_iw Testbench...\n");

    clk = 0;
    reset = 1;

    // Apply reset with safe input values
    regwritem   = 0;
    resultsrcm  = 2'b00;

    #10; // rising edge of clk
    #10; // falling edge
    reset = 0;

    // Wait one more clock to latch reset output
    #10; clk = 1; #10; clk = 0;
    print_state("After reset", 0, 2'b00);

    // First input transfer
    regwritem   = 1;
    resultsrcm  = 2'b10;
    #10; clk = 1; #10; clk = 0;
    print_state("First transfer", 1, 2'b10);

    // Second input transfer
    regwritem   = 0;
    resultsrcm  = 2'b01;
    #10; clk = 1; #10; clk = 0;
    print_state("Second transfer", 0, 2'b01);

    $display("Testbench complete.");
    $finish;
  end

endmodule
