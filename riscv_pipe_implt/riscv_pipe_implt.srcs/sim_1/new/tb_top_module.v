`timescale 1ns/1ps

module tb_top_module;

  reg         clk;
  reg         reset;
  wire        memwrite;
  wire [31:0] writedata;
  wire [31:0] dataadr;

  // DUT instantiation
  top_module dut (
    .clk        (clk),
    .reset      (reset),
    .writedatam (writedata),
    .dataadrm   (dataadr),
    .memwritem  (memwrite)
  );

  initial begin
    $display("Simulation starts!");
    reset = 1;
    clk   = 0;

    #20;
    reset = 0;

    // Run simulation for 500 clock cycles
    repeat (500) begin
      @(posedge clk);
      $display("[%0t] Addr = 0x%08x, WriteData = 0x%08x, MemWrite = %b",
                $time, dataadr, writedata, memwrite);
    end

    $finish;
  end

  // Clock generation
  always #5 clk = ~clk;

endmodule
