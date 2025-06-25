`timescale 1ns/1ps

module tb_id_iex;

  reg         clk;
  reg         reset;
  reg         clear;
  reg  [31:0] rd1d;
  reg  [31:0] rd2d;
  reg  [31:0] pcd;
  reg  [4:0]  rs1d;
  reg  [4:0]  rs2d;
  reg  [4:0]  rdd;
  reg  [31:0] immextd;
  reg  [31:0] pcplus4d;

  wire [31:0] rd1e;
  wire [31:0] rd2e;
  wire [31:0] pce;
  wire [4:0]  rs1e;
  wire [4:0]  rs2e;
  wire [4:0]  rde;
  wire [31:0] immexte;
  wire [31:0] pcplus4e;

  id_iex dut (
    .clk        (clk),
    .reset      (reset),
    .clear      (clear),
    .rd1d       (rd1d),
    .rd2d       (rd2d),
    .pcd        (pcd),
    .rs1d       (rs1d),
    .rs2d       (rs2d),
    .rdd        (rdd),
    .immextd    (immextd),
    .pcplus4d   (pcplus4d),
    .rd1e       (rd1e),
    .rd2e       (rd2e),
    .pce        (pce),
    .rs1e       (rs1e),
    .rs2e       (rs2e),
    .rde        (rde),
    .immexte    (immexte),
    .pcplus4e   (pcplus4e)
  );

  task check_outputs;
    input [31:0] exp_rd1e, exp_rd2e, exp_pce, exp_immexte, exp_pcplus4e;
    input [4:0]  exp_rs1e, exp_rs2e, exp_rde;
  begin
    #1;
    $display("[%0t] Checking Outputs", $time);
    $display("  Signal       | Expected      | Actual        | Result");
    $display("  -------------+---------------+---------------+--------");
    $display("  rd1e         | %08x | %08x | %s", exp_rd1e, rd1e, (rd1e === exp_rd1e) ? "PASS" : "FAIL");
    $display("  rd2e         | %08x | %08x | %s", exp_rd2e, rd2e, (rd2e === exp_rd2e) ? "PASS" : "FAIL");
    $display("  pce          | %08x | %08x | %s", exp_pce, pce, (pce === exp_pce) ? "PASS" : "FAIL");
    $display("  rs1e         | %02x         | %02x         | %s", exp_rs1e, rs1e, (rs1e === exp_rs1e) ? "PASS" : "FAIL");
    $display("  rs2e         | %02x         | %02x         | %s", exp_rs2e, rs2e, (rs2e === exp_rs2e) ? "PASS" : "FAIL");
    $display("  rde          | %02x         | %02x         | %s", exp_rde, rde, (rde === exp_rde) ? "PASS" : "FAIL");
    $display("  immexte      | %08x | %08x | %s", exp_immexte, immexte, (immexte === exp_immexte) ? "PASS" : "FAIL");
    $display("  pcplus4e     | %08x | %08x | %s", exp_pcplus4e, pcplus4e, (pcplus4e === exp_pcplus4e) ? "PASS" : "FAIL");
    $display("");
  end
  endtask

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Running id_iex pipeline register test...\n");

    reset = 1; clear = 0;
    rd1d = 0; rd2d = 0; pcd = 0;
    rs1d = 0; rs2d = 0; rdd = 0;
    immextd = 0; pcplus4d = 0;

    #12 reset = 0;

    // Test 1: Normal write
    #3;
    rd1d = 32'hA0000001;
    rd2d = 32'hA0000002;
    pcd = 32'h00400000;
    rs1d = 5'd5;
    rs2d = 5'd6;
    rdd = 5'd7;
    immextd = 32'hDEADBEEF;
    pcplus4d = 32'h00400004;
    #10;
    check_outputs(32'hA0000001, 32'hA0000002, 32'h00400000, 32'hDEADBEEF, 32'h00400004, 5'd5, 5'd6, 5'd7);

    // Test 2: Clear
    clear = 1;
    #10;
    check_outputs(0, 0, 0, 0, 0, 0, 0, 0);
    clear = 0;

    // Test 3: Reset
    rd1d = 32'h12345678;
    #10 reset = 1;
    #10;
    check_outputs(0, 0, 0, 0, 0, 0, 0, 0);

    $display("Test complete.");
    $finish;
  end

endmodule
