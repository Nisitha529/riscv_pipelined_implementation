`timescale 1ns/1ps

module tb_iex_imem;

  reg         clk;
  reg         reset;
  reg  [31:0] aluresulte;
  reg  [31:0] writedatae;
  reg  [4:0]  rde;
  reg  [31:0] pcplus4e;

  wire [31:0] aluresulm;
  wire [31:0] writedatm;
  wire [4:0]  rdm;
  wire [31:0] pcplus4m;

  iex_imem dut (
    .clk        (clk),
    .reset      (reset),
    .aluresulte (aluresulte),
    .writedatae (writedatae),
    .rde        (rde),
    .pcplus4e   (pcplus4e),
    .aluresulm  (aluresulm),
    .writedatm  (writedatm),
    .rdm        (rdm),
    .pcplus4m   (pcplus4m)
  );

  task check_outputs;
    input [31:0] exp_aluresulm, exp_writedatm, exp_pcplus4m;
    input [4:0]  exp_rdm;
  begin
    #1;
    $display("[%0t] Checking Outputs", $time);
    $display("  Signal       | Expected      | Actual        | Result");
    $display("  -------------+---------------+---------------+--------");
    $display("  aluresulm    | %08x | %08x | %s", exp_aluresulm, aluresulm, (aluresulm === exp_aluresulm) ? "PASS" : "FAIL");
    $display("  writedatm    | %08x | %08x | %s", exp_writedatm, writedatm, (writedatm === exp_writedatm) ? "PASS" : "FAIL");
    $display("  rdm          | %02x         | %02x         | %s", exp_rdm, rdm, (rdm === exp_rdm) ? "PASS" : "FAIL");
    $display("  pcplus4m     | %08x | %08x | %s", exp_pcplus4m, pcplus4m, (pcplus4m === exp_pcplus4m) ? "PASS" : "FAIL");
    $display("");
  end
  endtask

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Running iex_imem pipeline register test...\n");

    reset = 1;
    aluresulte = 0; writedatae = 0;
    rde = 0; pcplus4e = 0;
    #12 reset = 0;

    // Test 1: Normal write
    #3;
    aluresulte = 32'h0000ABCD;
    writedatae = 32'hDEADBEEF;
    rde = 5'd13;
    pcplus4e = 32'h00400004;
    #10;
    check_outputs(32'h0000ABCD, 32'hDEADBEEF, 32'h00400004, 5'd13);

    // Test 2: Reset
    reset = 1;
    #10;
    check_outputs(0, 0, 0, 0);

    $display("Test complete.");
    $finish;
  end

endmodule
