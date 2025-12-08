import uvm_pkg::*;       
`include "uvm_macros.svh" 

class monitor extends uvm_monitor ;
  `uvm_component_utils(monitor)

  virtual intf monitor_intf;
  uvm_analysis_port #(seq_item) monitor_ap;
  seq_item monitor_item;

  function new(string name = "monitor" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual intf)::get(this, "*","risc_intf", monitor_intf))
      `uvm_fatal("MONITOR", "Failed to get Interface");
    
    monitor_ap  = new("monitor_ap",this);
  endfunction : build_phase

  task  run_phase(uvm_phase phase);
    super.run_phase(phase);
	
    forever begin 
      monitor_item            = seq_item::type_id::create("monitor_item");
         
      @(posedge monitor_intf.clk); 	
     
      monitor_item.reset      = monitor_intf.reset;
     
      monitor_item.instrf     = monitor_intf.instrf;
      monitor_item.pcf        = monitor_intf.pcf;	
      monitor_item.readdatam  = monitor_intf.readdatam;
     
      monitor_item.writedatam = monitor_intf.writedatam;
      monitor_item.dataadrm   = monitor_intf.dataadrm;
      monitor_item.memwritem  = monitor_intf.memwritem;
     
      monitor_item.inst_type  = monitor_intf.inst_type;
     
      #1;
      
      monitor_ap.write(monitor_item);
    end 
    
  endtask : run_phase  

endclass 