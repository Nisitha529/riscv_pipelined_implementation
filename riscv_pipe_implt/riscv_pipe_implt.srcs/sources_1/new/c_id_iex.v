module c_id_iex(
  input              clk,
  input              reset,
  input              clear,
  input              regwrited,
  input              memwrited,
  input              jumpd,
  input              branchd,
  input              alusrcad,
  input  [1:0]       alusrcbd,
  input  [1:0]       resultsrcd,
  input  [3:0]       alucontrold,
  input  [2:0]       funct3d,
  output reg         regwritee,
  output reg         memwritee,
  output reg         jumpe,
  output reg         branche,
  output reg         alusrcae,
  output reg  [1:0]  alusrcbe,
  output reg  [1:0]  resultsrce,
  output reg  [3:0]  alucontrole,
  output reg  [2:0]  funct3e
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      regwritee    <= 0;
      memwritee    <= 0;
      jumpe        <= 0;
      branche      <= 0;
      alusrcae     <= 0;
      alusrcbe     <= 0;
      resultsrce   <= 0;
      alucontrole  <= 0;
      funct3e      <= 0;
    end
    else if (clear) begin
      regwritee    <= 0;
      memwritee    <= 0;
      jumpe        <= 0;
      branche      <= 0;
      alusrcae     <= 0;
      alusrcbe     <= 0;
      resultsrce   <= 0;
      alucontrole  <= 0;
      funct3e      <= 0;
    end
    else begin
      regwritee    <= regwrited;
      memwritee    <= memwrited;
      jumpe        <= jumpd;
      branche      <= branchd;
      alusrcae     <= alusrcad;
      alusrcbe     <= alusrcbd;
      resultsrce   <= resultsrcd;
      alucontrole  <= alucontrold;
      funct3e      <= funct3d;
    end
  end

endmodule
