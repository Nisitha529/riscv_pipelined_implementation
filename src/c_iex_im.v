module c_iex_im(
  input             clk,
  input             reset,
  input             regwritee,
  input             memwritee,
  input       [1:0] resultsrce,
  output reg        regwritem,
  output reg        memwritem,
  output reg  [1:0] resultsrcm
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      regwritem   <= 0;
      memwritem   <= 0;
      resultsrcm  <= 0;
    end
    else begin
      regwritem   <= regwritee;
      memwritem   <= memwritee;
      resultsrcm  <= resultsrce;
    end
  end

endmodule
