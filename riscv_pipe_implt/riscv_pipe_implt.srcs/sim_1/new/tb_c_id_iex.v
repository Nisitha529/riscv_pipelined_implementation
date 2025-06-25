`timescale 1ns/1ps

module tb_c_id_iex;

  reg         clk;
  reg         reset;
  reg         clear;
  reg         regwrited;
  reg         memwrited;
  reg         jumpd;
  reg         branchd;
  reg         alusrcad;
  reg  [1:0]  alusrcbd;
  reg  [1:0]  resultsrcd;
  reg  [3:0]  alucontrold;

  wire        regwritee;
  wire        memwritee;
  wire        jumpe;
  wire        branche;
  wire        alusrcae;
  wire [1:0]  alusrcbe;
  wire [1:0]  resultsrce;
  wire [3:0]  alucontrole;

  c_id_iex dut (
    .clk         (clk),
    .reset       (reset),
    .clear       (clear),
    .regwrited   (regwrited),
    .memwrited   (memwrited),
    .jumpd       (jumpd),
    .branchd     (branchd),
    .alusrcad    (alusrcad),
    .alusrcbd    (alusrcbd),
    .resultsrcd  (resultsrcd),
    .alucontrold (alucontrold),
    .regwritee   (regwritee),
    .memwritee   (memwritee),
    .jumpe       (jumpe),
    .branche     (branche),
    .alusrcae    (alusrcae),
    .alusrcbe    (alusrcbe),
    .resultsrce  (resultsrce),
    .alucontrole (alucontrole)
  );

  task print_state(input [127:0] label, input [3:0] exp_alucontrol,
                   input [1:0] exp_resultsrc, input [1:0] exp_alusrcb,
                   input exp_regwrite, input exp_memwrite,
                   input exp_jump, input exp_branch, input exp_alusrca);
  begin
    $display("[%0t] %-20s", $time, label);
    $display("         Signal        |  Expected  |  Received");
    $display("  ---------------------+------------+-----------");
    $display("  regwritee            |     %b      |     %b", exp_regwrite, regwritee);
    $display("  memwritee            |     %b      |     %b", exp_memwrite, memwritee);
    $display("  jumpe                |     %b      |     %b", exp_jump, jumpe);
    $display("  branche              |     %b      |     %b", exp_branch, branche);
    $display("  alusrcae             |     %b      |     %b", exp_alusrca, alusrcae);
    $display("  alusrcbe             |     %02b     |     %02b", exp_alusrcb, alusrcbe);
    $display("  resultsrce           |     %02b     |     %02b", exp_resultsrc, resultsrce);
    $display("  alucontrole          |    %04b     |    %04b", exp_alucontrol, alucontrole);
    $display("");
  end
  endtask

  initial begin
    $display("Running c_id_iex Testbench...\n");

    clk = 0;
    reset = 1;
    clear = 0;
    regwrited    = 1;
    memwrited    = 1;
    jumpd        = 1;
    branchd      = 1;
    alusrcad     = 1;
    alusrcbd     = 2'b10;
    resultsrcd   = 2'b01;
    alucontrold  = 4'b1010;

    #5  clk = 1; #5  clk = 0; // rising edge (apply reset)
    reset = 0;

    #5  clk = 1; #5  clk = 0; // data capture after reset released
    print_state("After initial input", 4'b1010, 2'b01, 2'b10, 1, 1, 1, 1, 1);

    // Clear applied
    clear = 1;
    regwrited    = 0;
    #5  clk = 1; #5  clk = 0;
    print_state("After clear", 4'b0000, 2'b00, 2'b00, 0, 0, 0, 0, 0);

    // Normal data transfer again
    clear         = 0;
    regwrited     = 1;
    memwrited     = 0;
    jumpd         = 0;
    branchd       = 1;
    alusrcad      = 0;
    alusrcbd      = 2'b01;
    resultsrcd    = 2'b10;
    alucontrold   = 4'b1111;

    #5  clk = 1; #5  clk = 0;
    print_state("After data transfer", 4'b1111, 2'b10, 2'b01, 1, 0, 0, 1, 0);

    $display("Testbench complete.");
    $finish;
  end

endmodule
