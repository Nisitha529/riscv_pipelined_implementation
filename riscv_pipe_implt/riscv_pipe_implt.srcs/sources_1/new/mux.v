`timescale 1ns / 1ps

module mux (
    input      [31:0] a,
    input      [31:0] b,
    input             s,
    output     [31:0] c
);

assign c = (~s) ? a : b ;

endmodule