import uvm_pkg::*;       
`include "uvm_macros.svh" 

class driver extends uvm_driver #(seq_item);
  `uvm_component_utils(driver)

  seq_item driver_item;
  virtual intf driver_intf;

  function new (string name = "driver" ,uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase (uvm_phase phase);  
    super.build_phase(phase);
    
    if(!(uvm_config_db #(virtual intf)::get(this,"*","risc_intf",driver_intf))) 
   `uvm_error(get_type_name(),"failed to get virtual interface inside Driver class")   

  endfunction : build_phase 
 
  task run_phase (uvm_phase phase);   
    super.run_phase(phase);  
    forever begin      
      driver_item = seq_item::type_id::create("driver_item");
           
      seq_item_port.get_next_item(driver_item);
      
      drive(driver_item);
      seq_item_port.item_done();    
      
    end   
    
  endtask : run_phase 

  task drive (seq_item RISC_item);
    @(posedge driver_intf.clk);
     driver_intf.reset     <= RISC_item.reset;
     driver_intf.instrf    <= RISC_item.instrf;
     driver_intf.inst_type <= RISC_item.inst_type;
     
  endtask : drive
 
endclass : driver