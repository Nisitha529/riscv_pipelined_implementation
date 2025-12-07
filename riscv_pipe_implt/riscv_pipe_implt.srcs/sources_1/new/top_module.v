module top_module (
  input         clk,
  input         reset,
  
  input  [31:0] instrf,
  output [31:0] pcf,
  output [31:0] readdatam,
  
  output [31:0] writedatam,
  output [31:0] dataadrm,
  output        memwritem
);

  wire [31:0] pcf;
  wire [31:0] instrf;
  wire [31:0] readdatam_w;
  
  assign readdatam = readdatam_w;

  // instantiate processor and memories
  riscv_module rv (
    .clk         (clk),
    .reset       (reset),
    .pcf         (pcf),
    .instrf      (instrf),
    .memwritem   (memwritem),
    .aluresultm  (dataadrm),
    .writedatam  (writedatam),
    .readdatam   (readdatam_w)
  );

//  imem imem_inst (
//    .a  (pcf),
//    .rd (instrf)
//  );

  dmem dmem_inst (
    .clk   (clk),
    .we    (memwritem),
    .a     (dataadrm),
    .wd    (writedatam),
    .rd    (readdatam_w)
  );

endmodule
