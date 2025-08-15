module datapath(
  input             clk,
  input             reset,
  input      [1:0]  resultsrcw,
  input             pcjalsrce,
  input             pcsrce,
  input             alusrcae,
  input      [1:0]  alusrcbe,
  input             regwritew,
  input      [2:0]  immsrcd,
  input      [3:0]  alucontrole,
  output            zeroe,
  output            signe,
  output     [31:0] pcf,
  input      [31:0] instrf,
  output     [31:0] instrd,
  output     [31:0] aluresultm,
  output     [31:0] writedatam,
  input      [31:0] readdatam,
  input      [1:0]  forwardae,
  input      [1:0]  forwardbe,
  output     [4:0]  rs1d,
  output     [4:0]  rs2d,
  output     [4:0]  rs1e,
  output     [4:0]  rs2e,
  output     [4:0]  rde,
  output     [4:0]  rdm,
  output     [4:0]  rdw,
  input             stalld,
  input             stallf,
  input             flushd,
  input             flushe
);

  wire [31:0] pcd, pce, aluresulte, aluresultw, readdataw;
  wire [31:0] pcnextf, pcplus4f, pcplus4d, pcplus4e, pcplus4m, pcplus4w;
  wire [31:0] pctargete, branjumptargete;
  wire        pcjalsrcm;
  wire [31:0] writedatae, immextd, immexte;
  wire [31:0] srcaefor, srcae, srcbe;
  wire [31:0] rd1d, rd2d, rd1e, rd2e;
  wire [31:0] resultw;
  wire [4:0]  rdd;

  // fetch stage
  mux2 u_jal_r(
    .d0       (pctargete),
    .d1       (aluresulte),
    .s        (pcjalsrcm),
    .y        (branjumptargete)
  );

  mux2 u_pcmux(
    .d0       (pcplus4f),
    .d1       (branjumptargete),
    .s        (pcsrce),
    .y        (pcnextf)
  );

  flopenr u_if(
    .clk      (clk),
    .reset    (reset),
    .en       (~stallf),
    .d        (pcnextf),
    .q        (pcf)
  );

  adder u_pcadd4(
    .a        (pcf),
    .b        (32'd4),
    .y        (pcplus4f)
  );

  // if-id
  if_id u_if_id(
    .clk       (clk),
    .reset     (reset),
    .clear     (flushd),
    .enable    (~stalld),
    .instrf    (instrf),
    .pcf       (pcf),
    .pcplus4f  (pcplus4f),
    .instrd    (instrd),
    .pcd       (pcd),
    .pcplus4d  (pcplus4d)
  );

  assign rs1d = instrd[19:15];
  assign rs2d = instrd[24:20];
  assign rdd  = instrd[11:7];

  regfile u_rf(
    .clk   (clk),
    .we3   (regwritew),
    .a1    (rs1d),
    .a2    (rs2d),
    .a3    (rdw),
    .wd3   (resultw),
    .rd1   (rd1d),
    .rd2   (rd2d)
  );

  extend u_ext(
    .instr   (instrd[31:7]),
    .immsrc  (immsrcd),
    .immext  (immextd)
  );

  // id-ex
  id_iex u_id_iex(
    .clk        (clk),
    .reset      (reset),
    .clear      (flushe),
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

  mux3 u_forwardae(
    .d0  (rd1e),
    .d1  (resultw),
    .d2  (aluresultm),
    .s   (forwardae),
    .y   (srcaefor)
  );

  mux2 u_srcamux(
    .d0  (srcaefor),
    .d1  (32'b0),
    .s   (alusrcae),
    .y   (srcae)
  );

  mux3 u_forwardbe(
    .d0  (rd2e),
    .d1  (resultw),
    .d2  (aluresultm),
    .s   (forwardbe),
    .y   (writedatae)
  );

  mux3 u_srcbmux(
    .d0  (writedatae),
    .d1  (immexte),
    .d2  (pctargete),
    .s   (alusrcbe),
    .y   (srcbe)
  );

  adder u_pcaddbranch(
    .a  (pce),
    .b  (immexte),
    .y  (pctargete)
  );

  alu u_alu(
    .srca       (srcae),
    .srcb       (srcbe),
    .alucontrol (alucontrole),
    .aluresult  (aluresulte),
    .zero       (zeroe),
    .sign       (signe)
  );

  // ex-mem
  iex_imem u_iex_imem(
    .clk         (clk),
    .reset       (reset),
    .pcjalsrce   (pcjalsrce),
    .aluresulte  (aluresulte),
    .writedatae  (writedatae),
    .rde         (rde),
    .pcplus4e    (pcplus4e),
    .aluresulm   (aluresultm),
    .writedatm   (writedatam),
    .rdm         (rdm),
    .pcplus4m    (pcplus4m),
    .pcjalsrcm   (pcjalsrcm)
  );

  // mem-wb
  imem_iw u_imem_iw(
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

  mux3 u_resultmux(
    .d0  (aluresultw),
    .d1  (readdataw),
    .d2  (pcplus4w),
    .s   (resultsrcw),
    .y   (resultw)
  );

endmodule