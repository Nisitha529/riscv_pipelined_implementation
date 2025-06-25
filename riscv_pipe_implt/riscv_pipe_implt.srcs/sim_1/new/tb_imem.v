`timescale 1ns/1ps

module tb_imem;

  reg  [31:0] a;
  wire [31:0] rd;

  imem dut (
    .a  (a),
    .rd (rd)
  );

  task check_instr(
    input [31:0] addr,
    input [31:0] expected,
    input [127:0] label
  );
  begin
    a = addr;
    #1;
    $display("[%0t] %-20s | Addr: %02x | Expected: %08x | Actual: %08x | %s",
             $time, label, addr, expected, rd,
             (rd === expected) ? "PASS" : "FAIL");
  end
  endtask

  initial begin
    $display("\nRunning imem test...\n");

    // Check first 5 instructions
    check_instr(32'd0,  32'h00f00093, "Instr 0: addi x1, x0, 15");
    check_instr(32'd4,  32'h01600113, "Instr 1: addi x2, x0, 22");
    check_instr(32'd8,  32'h002081b3, "Instr 2: add x3, x1, x2");
    check_instr(32'd12, 32'h0021e233, "Instr 3: and x4, x3, x2");
    check_instr(32'd16, 32'h0041c2b3, "Instr 4: xor x5, x3, x4");

    // Additional checks (optional)
    check_instr(32'd20, 32'h00428333, "Instr 5: add x6, x5, x4");
    check_instr(32'd24, 32'h02628863, "Instr 6: bne x5, x6, ...");
    check_instr(32'd28, 32'h0041a233, "Instr 7: xor x4, x3, x4");

    $display("\nTest complete.");
    $finish;
  end

endmodule
