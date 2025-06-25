`timescale 1ns/1ps

module tb_imem_iw;

  reg         clk;
  reg         reset;
  reg  [31:0] aluresultm;
  reg  [31:0] readdatam;
  reg  [4:0]  rdm;
  reg  [31:0] pcplus4m;
  wire [31:0] aluresultw;
  wire [31:0] readdataw;
  wire [4:0]  rdw;
  wire [31:0] pcplus4w;

  imem_iw dut (
    .clk         (clk),
    .reset       (reset),
    .aluresultm  (aluresultm),
    .readdatam   (readdatam),
    .rdm         (rdm),
    .pcplus4m    (pcplus4m),
    .aluresultw  (aluresultw),
    .readdataw   (readdataw),
    .rdw         (rdw),
    .pcplus4w    (pcplus4w)
  );

  task check(
    input [127:0] label,
    input [31:0]  exp_alu,
    input [31:0]  exp_data,
    input [4:0]   exp_rd,
    input [31:0]  exp_pc
  );
  begin
    #1;
    $display("[%0t] %-15s | ALU: %08x | Data: %08x | Rd: %02d | PC+4: %08x | %s",
      $time, label, aluresultw, readdataw, rdw, pcplus4w,
      ((aluresultw === exp_alu) &&
       (readdataw  === exp_data) &&
       (rdw        === exp_rd) &&
       (pcplus4w   === exp_pc)) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Running IMem_IW test...\n");

    reset = 1;
    aluresultm = 32'h00000000;
    readdatam  = 32'h00000000;
    rdm        = 5'd0;
    pcplus4m   = 32'h00000000;
    #12; reset = 0;

    // First transfer
    #3;
    aluresultm = 32'hA1A1A1A1;
    readdatam  = 32'h12345678;
    rdm        = 5'd10;
    pcplus4m   = 32'h00000004;
    #10;
    check("First transfer", 32'hA1A1A1A1, 32'h12345678, 5'd10, 32'h00000004);

    // Second transfer
    #10;
    aluresultm = 32'hBEEFCAFE;
    readdatam  = 32'h87654321;
    rdm        = 5'd12;
    pcplus4m   = 32'h00000008;
    #10;
    check("Second transfer", 32'hBEEFCAFE, 32'h87654321, 5'd12, 32'h00000008);

    // Reset again
    #10;
    reset = 1;
    #10;
    check("After reset", 32'h00000000, 32'h00000000, 5'd0, 32'h00000000);

    $display("\nTest complete.");
    $finish;
  end

endmodule
