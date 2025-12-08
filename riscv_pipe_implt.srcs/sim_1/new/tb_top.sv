`timescale 1ns/1ns
`include "uvm_macros.svh"

module tb_top;
    
  import uvm_pkg::*;
  import risc_pkg::* ;
    
  bit clk ;
    
  string blk_hdl_path = "tb_top.dut";
  string mem_hdl_path = "dmem.RAM";
  string reg_hdl_path = "rv.dp.rf.register[%0d]";

  intf risc_intf(clk);

  top_module  dut (
    .clk        (clk),   
    .reset      (risc_intf.reset), 
    
    .instrf     (risc_intf.instrf),	
    .pcf        (risc_intf.pcf),
    .readdatam  (risc_intf.readdatam),
    
    .writedatam (risc_intf.writedatam),
    .dataadrm   (risc_intf.dataadrm),
    .memwritem  (risc_intf.memwritem)
  );

  initial begin 
    forever  #5 clk = ~clk;
  end
  
  initial begin 
    uvm_config_db #(virtual intf)::set(null,"*","risc_intf",risc_intf);
    uvm_config_db #(string)::set(null,"*", "blk_hdl_path", blk_hdl_path);
    uvm_config_db #(string)::set(null,"*", "mem_hdl_path", mem_hdl_path);
    uvm_config_db #(string)::set(null,"*", "reg_hdl_path", reg_hdl_path);
    run_test();
  end
    
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  
endmodule 
