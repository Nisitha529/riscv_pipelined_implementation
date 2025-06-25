`timescale 1ns/1ps

module tb_alu;

  reg  [31:0] srca;
  reg  [31:0] srcb;
  reg  [3:0]  alucontrol;
  wire [31:0] aluresult;
  wire        zero;
  wire        sign;

  alu dut (
    .srca       (srca),
    .srcb       (srcb),
    .alucontrol (alucontrol),
    .aluresult  (aluresult),
    .zero       (zero),
    .sign       (sign)
  );

  task check_result;
    input [127:0] op;
    input [31:0]  expected;
    begin
      #1;
      $display("[%0t] %-14s | Expected: %08x | Actual: %08x | %s",
               $time, op, expected, aluresult,
               (aluresult === expected) ? "PASS" : "FAIL");
    end
  endtask

  initial begin
    $display("Running ALU test...\n");

    // Test ADD
    srca = 32'd10; srcb = 32'd5; alucontrol = 4'b0000;
    #2; check_result("ADD", 32'd15);

    // Test SUB
    srca = 32'd10; srcb = 32'd5; alucontrol = 4'b0001;
    #2; check_result("SUB", 32'd5);

    // Test AND
    srca = 32'hA5A5A5A5; srcb = 32'hFFFF0000; alucontrol = 4'b0010;
    #2; check_result("AND", 32'hA5A50000);

    // Test OR
    srca = 32'hA5A5A5A5; srcb = 32'hFFFF0000; alucontrol = 4'b0011;
    #2; check_result("OR", 32'hFFFFA5A5);

    // Test SLL
    srca = 32'h00000001; srcb = 32'd8; alucontrol = 4'b0100;
    #2; check_result("SLL", 32'h00000100);

    // Test SLT
    srca = 32'd5; srcb = 32'd10; alucontrol = 4'b0101;
    #2; check_result("SLT", 32'd1);

    // Test XOR
    srca = 32'hAAAA0000; srcb = 32'h55550000; alucontrol = 4'b0110;
    #2; check_result("XOR", 32'hFFFF0000);

    // Test SRL
    srca = 32'h00000100; srcb = 32'd2; alucontrol = 4'b0111;
    #2; check_result("SRL", 32'h00000040);

    // Test SLTU
    srca = 32'd5; srcb = 32'd10; alucontrol = 4'b1000;
    #2; check_result("SLTU", 32'd1);

    // Test SRA
    srca = -32'sd64; srcb = 32'd3; alucontrol = 4'b1111;
    #2; check_result("SRA", -32'sd8);

    $display("\nALU test complete.");
    $finish;
  end

endmodule
