module extend(
  input  [31:0] instr,
  input  [2:0]  immsrc,
  output reg [31:0] immext
);

  always @(*) begin
    case (immsrc)
      // I-type: e.g., addi
      3'b000: immext = {{20{instr[31]}}, instr[31:20]};

      // S-type: e.g., sw
      3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};

      // B-type: e.g., beq
      3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

      // J-type: e.g., jal
      3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

      // U-type: e.g., lui
      3'b100: immext = {instr[31:12], 12'b0};

      default: immext = 32'bx;
    endcase
  end

endmodule
