`timescale 1ns/1ps

module tb_c_iex_im;

  reg         clk;
  reg         reset;
  reg         regwritee;
  reg         memwritee;
  reg  [1:0]  resultsrce;

  wire        regwritem;
  wire        memwritem;
  wire [1:0]  resultsrcm;

  c_iex_im dut (
    .clk        (clk),
    .reset      (reset),
    .regwritee  (regwritee),
    .memwritee  (memwritee),
    .resultsrce (resultsrce),
    .regwritem  (regwritem),
    .memwritem  (memwritem),
    .resultsrcm (resultsrcm)
  );

  task print_state(
    input [127:0] label,
    input         exp_regwrite,
    input         exp_memwrite,
    input [1:0]   exp_resultsrc
  );
  begin
    $display("[%0t] %-20s", $time, label);
    $display("         Signal        |  Expected  |  Received");
    $display("  ---------------------+------------+-----------");
    $display("  regwritem            |     %b      |     %b", exp_regwrite, regwritem);
    $display("  memwritem            |     %b      |     %b", exp_memwrite, memwritem);
    $display("  resultsrcm           |     %02b     |     %02b", exp_resultsrc, resultsrcm);
    $display("");
  end
  endtask

  // Clock generation
  always #5 clk = ~clk;

  initial begin
    $display("Running c_iex_im Testbench...\n");

    // Initialize
    clk = 0;
    reset = 1;
    regwritee = 0;
    memwritee = 0;
    resultsrce = 2'b00;

    // Apply reset and clock
    #10;  // let reset propagate
    reset = 0;
    #10;  // one clock after reset released
    print_state("After reset", 0, 0, 2'b00);

    // First input transfer
    regwritee = 1;
    memwritee = 1;
    resultsrce = 2'b11;
    #10;
    print_state("First input transfer", 1, 1, 2'b11);

    // Second input transfer
    regwritee = 1;
    memwritee = 0;
    resultsrce = 2'b10;
    #10;
    print_state("Second transfer", 1, 0, 2'b10);

    // Third input transfer
    regwritee = 0;
    memwritee = 1;
    resultsrce = 2'b01;
    #10;
    print_state("Third transfer", 0, 1, 2'b01);

    $display("Testbench complete.");
    $finish;
  end

endmodule
