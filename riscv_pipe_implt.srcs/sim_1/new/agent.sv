import uvm_pkg::*;       
`include "uvm_macros.svh" 

class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  driver risc_driver;
  monitor risc_monitor;
  sequencer risc_sequencer;
 
  function new(string name = "agent" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
    
    risc_driver    = driver::type_id::create("risc_driver",this);
    risc_monitor   = monitor::type_id::create("risc_monitor",this);
    risc_sequencer = sequencer::type_id::create("risc_sequencer",this); 
    
  endfunction : build_phase 

  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);	  
	 risc_driver.seq_item_port.connect(risc_sequencer.seq_item_export); 
  endfunction :connect_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase

endclass : agent 