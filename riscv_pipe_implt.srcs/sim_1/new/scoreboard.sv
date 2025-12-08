class scoreboard extends uvm_scoreboard ;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(seq_item, scoreboard) sb_mon_port;

  seq_item sb_item;  
  seq_item p_item; 
  
  seq_item fetch_seq, dec_seq, ex_seq, mem_seq, wr_seq; 
  
  ral_model ral_model_h; 
  uvm_status_e   status;  

  logic [31:0] mem_forward , wr_forward; 
  logic [31:0] srcA , srcB;
  logic [31:0] mem_data , reg_data;
  logic [31:0] branch_result;
  logic [31:0] regfile_comp;
  logic [31:0] jal_rd;
  bit   [1:0]  forward_A , forward_B;
  bit          lwstall;
  bit          beqflush;

  function new (string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    sb_mon_port = new ("sb_mon_port" ,this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase) ;  
    
    if (!uvm_config_db #(ral_model)::get(null, "", "ral_model_h", ral_model_h ))
      `uvm_error(get_type_name(), "RAL model not found" );  
    
    fetch_seq = seq_item::type_id::create("fetch_seq");
    dec_seq   = seq_item::type_id::create("dec_seq");
    ex_seq    = seq_item::type_id::create("ex_seq");
    mem_seq   = seq_item::type_id::create("mem_seq");
    wr_seq    = seq_item::type_id::create("wr_seq");
    
  endfunction : build_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    ral_model_h.initialize; 
    
  endtask

  function void write(seq_item t);  
    sb_item = seq_item::type_id::create("sb_item"); 
    p_item  = seq_item::type_id::create("p_item");
    sb_item.copy(t) ;       
    
    if (sb_item.reset) begin 
      fetch_seq.Reset();
      dec_seq.Reset();
      ex_seq.Reset();
      mem_seq.Reset();
      wr_seq.Reset();
      p_item.Reset();
      compare(sb_item,p_item);
      
    end else begin
      wr_seq.copy(mem_seq);   
         
      if(ex_seq.lwstall == 0) 
        mem_seq.copy(ex_seq); 
      else 
        mem_seq.lwstall = ex_seq.lwstall;
        
      ex_seq.copy(dec_seq); 
      dec_seq.copy(fetch_seq); 
      fetch_seq.copy(sb_item);

      if ((ex_seq.instrf[19:15] == mem_seq.instrf[11:7]) && (ex_seq.instrf[19:15] != 0) && (mem_seq.instrf[6:0] != brnch) && (mem_seq.instrf[6:0] != sw)) 
        forward_A = 2'b10; 
      else if ((ex_seq.instrf[19:15] == wr_seq.instrf[11:7]) && (ex_seq.instrf[19:15] != 0) && (wr_seq.instrf[6:0] != brnch) && (wr_seq.instrf[6:0] != sw))
        forward_A = 2'b01;
      else 
        forward_A = 2'b00;  
      
      if ((ex_seq.instrf[24:20] == mem_seq.instrf[11:7]) && (ex_seq.instrf[24:20] != 0) && (mem_seq.instrf[6:0] != brnch) && (mem_seq.instrf[6:0] != sw)) 
        forward_B = 2'b10;
      else if ((ex_seq.instrf[24:20] == wr_seq.instrf[11:7]) && (ex_seq.instrf[24:20] != 0) && (wr_seq.instrf[6:0] != brnch) && (wr_seq.instrf[6:0] != sw))
        forward_B = 2'b01; 
      else 
        forward_B = 2'b00; 
      
      `uvm_info("FORWARD_CHECK", $sformatf("forward_A: %d, forward_B: %d", forward_A, forward_B), UVM_HIGH)

       fork 
         begin
         predict();  
         compare(sb_item,p_item) ;
         end
       join_none         
    end
    
  endfunction: write 
  
  task predict ();    
    p_item = seq_item::type_id::create("p_item");
    
    ral_model_h.regs[mem_seq.instrf[19:15]].read(status, srcA, UVM_BACKDOOR); 
    ral_model_h.regs[mem_seq.instrf[24:20]].read(status, srcB, UVM_BACKDOOR); 
    ral_model_h.regs[wr_seq.instrf[11:7]].read(status, reg_data, UVM_BACKDOOR);    
    ral_model_h.dmem.read(status , fetch_seq.dataadrm[9:2] , mem_data, UVM_BACKDOOR); 
     
    branch_result    = srcA - srcB;

    dec_seq.beqflush = (mem_seq.beqflush || ex_seq.beqflush || ex_seq.lwstall) ? 0 : ((mem_seq.inst_type == BEQ) && (!branch_result) || (mem_seq.inst_type == BNE) && (branch_result) || (mem_seq.inst_type == BGE) && (!branch_result[31]) || (mem_seq.inst_type == BLT) && (branch_result[31]) || (mem_seq.inst_type == JAL) || (mem_seq.inst_type == JALR));
    
    `uvm_info("BEQFLUSH_CHECK", $sformatf("beqflush: %b", dec_seq.beqflush), UVM_HIGH)
    `uvm_info("OPERANDS_VALUES", $sformatf("srcA: %d, srcB: %d", srcA, srcB), UVM_HIGH)

    fetch_seq.lwstall = (dec_seq.beqflush || ex_seq.beqflush || dec_seq.lwstall) ? 0 : (ex_seq.instrf[6:0] == lw) && ((ex_seq.instrf[11:7] == dec_seq.instrf[19:15]) || (ex_seq.instrf[11:7] == dec_seq.instrf[24:20]));
    
    `uvm_info("LWSTALL_CHECK", $sformatf("lwstall: %b", fetch_seq.lwstall), UVM_HIGH)

    case (mem_seq.inst_type) 
       
      LW : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA + mem_seq.Extend; 
      end
           
      ADDI : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA + mem_seq.Extend;
      end
          
      SLLI : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA << mem_seq.instrf[24:20];       
      end
          
      SLTI : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : ($signed(srcA) < $signed(mem_seq.Extend));
      end
          
      XORI : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA ^ mem_seq.Extend;
      end
          
      SRAI : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA >>> mem_seq.instrf[24:20];
      end
            
      SRLI : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA >> mem_seq.instrf[24:20];  
      end 
          
      ORI : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA | mem_seq.Extend;
      end
          
      ANDI : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA & mem_seq.Extend;
      end 
          
      AUIPC : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4; 
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : mem_seq.pcf + {mem_seq.instrf[31:12] , 12'b0}; 
      end
      
      SW : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4; 
        p_item.memwritem  = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : 1;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA + mem_seq.Extend; 
        p_item.writedatam = srcB;
      end
           
      ADD : begin
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA + srcB; 
      end
          
      SUB : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA - srcB; 
      end
             
      SLL : begin   
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA << srcB[4:0];   
      end
          
      SLT : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : ($signed(srcA) < $signed(srcB));   
      end
          
      XOR : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA ^ srcB; 
      end  
          
      SRL : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA >> srcB[4:0]; 
      end  
      
      SRA : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA >>> srcB[4:0]; 
      end 

      OR : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA | srcB;    
      end  
        
      AND : begin  
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4;
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA & srcB;  
      end  
      
      LUI : begin 
        p_item.pcf        = dec_seq.lwstall ? dec_seq.pcf : dec_seq.pcf + 4; 
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : {mem_seq.instrf[31:12] , 12'b0}; 
      end
      
      BEQ : begin 
        p_item.memwritem  = 0; 
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA - srcB; 
        if (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall)
          p_item.pcf      = dec_seq.pcf + 4; 
        else 
          p_item.pcf      = dec_seq.lwstall ? dec_seq.pcf : p_item.dataadrm ? (dec_seq.pcf + 4) : (mem_seq.pcf + mem_seq.Extend);
      end
        
      BNE : begin 
        p_item.memwritem  = 0; 
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA - srcB;
        if (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall)
          p_item.pcf      = dec_seq.pcf + 4; 
        else
          p_item.pcf      = dec_seq.lwstall ? dec_seq.pcf : p_item.dataadrm ? (mem_seq.pcf + mem_seq.Extend) : (dec_seq.pcf + 4);
      end
        
      BLT : begin  
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA - srcB;  
        if (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall)
          p_item.pcf      = dec_seq.pcf + 4; 
        else
          p_item.pcf      = dec_seq.lwstall ? dec_seq.pcf : (p_item.dataadrm[31]) ? mem_seq.pcf + mem_seq.Extend : dec_seq.pcf + 4;
      end
        
      BGE : begin  
        p_item.memwritem  = 0;
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA - srcB;
        if (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall)
          p_item.pcf      = dec_seq.pcf + 4; 
        else
          p_item.pcf      = dec_seq.lwstall ? dec_seq.pcf : (!p_item.dataadrm[31]) ? mem_seq.pcf + mem_seq.Extend : dec_seq.pcf + 4;  
      end      
        
      JALR : begin 
        p_item.memwritem  = 0; 
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA + mem_seq.Extend ;
        p_item.pcf        = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? dec_seq.pcf +4 : dec_seq.lwstall ? dec_seq.pcf : srcA + mem_seq.Extend;
        jal_rd            = mem_seq.pcf + 4;
      end
        
      JAL : begin 
        p_item.memwritem  = 0; 
        p_item.dataadrm   = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? 0 : srcA + srcB;
        p_item.pcf        = (ex_seq.beqflush || mem_seq.beqflush || ex_seq.lwstall) ? dec_seq.pcf +4 : dec_seq.lwstall ? dec_seq.pcf : mem_seq.pcf + mem_seq.Extend;
        jal_rd            = mem_seq.pcf + 4;
      end
      
    endcase  
  endtask 
  
  function void compare (seq_item a_seq , p_seq);
  
    bit some_pass , reg_pass , mem_pass , all_pass; 
     
    if(mem_seq.instrf == 0) begin 
      `uvm_info(get_type_name(),"No Output yet ... In progress", UVM_HIGH)
    end else begin 
      
      if (wr_seq.instrf[6:0] == lw)  
        regfile_comp = dec_seq.readdatam;  
      else if ((wr_seq.inst_type == JAL) || (wr_seq.inst_type == JALR))
        regfile_comp = ((mem_seq.inst_type == JAL) || (mem_seq.inst_type == JALR)) ? jal_rd - 4 : jal_rd; 
      else 
        regfile_comp = dec_seq.dataadrm ;

      mem_pass   = (mem_data == fetch_seq.writedatam);  
      reg_pass   = (reg_data == regfile_comp);    
      some_pass  = (a_seq.dataadrm   === p_seq.dataadrm)  && (a_seq.memwritem  === p_seq.memwritem) && (a_seq.pcf === p_seq.pcf); 
      
      if ((mem_seq.instrf[6:0] == sw) && ((wr_seq.instrf[6:0] == sw) || (wr_seq.instrf[6:0] == brnch) || wr_seq.beqflush) && !ex_seq.beqflush && !mem_seq.beqflush) begin 
        all_pass = some_pass && mem_pass;
        `uvm_info("MEMORY_CHECK", $sformatf("Data read from memory: %h, Expected data: %h", mem_data, fetch_seq.writedatam), UVM_HIGH) 
      end else if ((mem_seq.instrf[6:0] == sw) && (wr_seq.instrf[6:0] != sw) && (wr_seq.instrf[6:0] != brnch) && !ex_seq.beqflush && !mem_seq.beqflush && !ex_seq.lwstall)  begin 
        all_pass = some_pass && mem_pass && reg_pass;
        `uvm_info("MEMORY_REGFILE_CHECK", $sformatf("Data read from memory: %h, Expected data: %h\nData read from regfile: %h, Expected data: %h",mem_data, fetch_seq.writedatam, reg_data, regfile_comp),UVM_HIGH)
      end else if (((mem_seq.instrf[6:0] != sw) && ((wr_seq.instrf[6:0] == sw) || (wr_seq.instrf[6:0] == brnch)))  || mem_seq.lwstall || mem_seq.beqflush || wr_seq.beqflush || (ex_seq.beqflush && (wr_seq.instrf[6:0] == brnch))) begin 
        all_pass = some_pass; 
      end else begin 
        all_pass = some_pass && reg_pass;
        `uvm_info("REGFILE_CHECK", $sformatf("Data read from regfile: %h, Expected data: %h", reg_data, regfile_comp), UVM_HIGH)
      end

      if (all_pass)
        `uvm_info(get_type_name(),"SUCCESSFUL OPERATION ", UVM_HIGH)
      else  
        `uvm_error(get_type_name(),"FAILED OPEARTION ")
        
    end 
    
  endfunction 

endclass : scoreboard
