`timescale 1ns/1ps

module tb_extend;

  reg  [31:0] instr;
  reg  [2:0]  immsrc;
  wire [31:0] immext;

  extend dut (
    .instr   (instr),
    .immsrc  (immsrc),
    .immext  (immext)
  );

  task test_case(
    input [127:0] label,
    input [31:0]  test_instr,
    input [2:0]   test_immsrc,
    input [31:0]  expected
  );
  begin
    instr   = test_instr;
    immsrc  = test_immsrc;
    #1;
    $display("[%0t] %s", $time, label);
    $display("  Expected: %08x | Actual: %08x | %s\n",
              expected, immext,
              (immext === expected) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    $display("Running extend unit test...\n");

    // I-type: addi x1, x2, -1 (imm = 0xFFF => sign-extended to FFFFFFFF)
    test_case("I-type -1", 32'b111111111111_00010_000_00001_0010011, 3'b000, 32'hFFFFFFFF);

    // S-type: sw x2, -4(x3)
    test_case("S-type -4", 32'b1111111_00010_00011_010_11100_0100011, 3'b001, 32'hFFFFFFFC);

    // B-type: beq x1,x2,8 -> imm=0000000001000 (shifted)
    test_case("B-type 8", 32'b00000000001000001000010001100011, 3'b010, 32'h00000008);

    // J-type: jal x1, 2048
    test_case("J-type 2048", 32'h0010006f, 3'b011, 32'h00000800);

    // U-type: LUI x1, 0x12345
    test_case("U-type", 32'b00010010001101000101_00001_0110111, 3'b100, 32'h12345000);

    $display("Test complete.");
    $finish;
  end

endmodule