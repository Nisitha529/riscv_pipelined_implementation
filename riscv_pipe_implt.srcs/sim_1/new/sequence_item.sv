import risc_pkg::* ;
import uvm_pkg::* ;

`include "uvm_macros.svh"

class seq_item extends uvm_sequence_item;

  function new (string name = "risc_seq_item") ;
    super.new(name);  
  endfunction
  
  rand logic          reset;
  
  rand bit   [31 : 0] instrf;
  logic      [31 : 0] pcf;
  logic      [31 : 0] readdatam;
  
  logic      [31 : 0] writedatam;
  logic      [31 : 0] dataadrm;
  logic               memwritem;
  
  // Auxiliary fields
  rand instr_type     inst_type;
  bit                 lwstall;
  bit                 beqflush;
  
  `uvm_object_utils_begin(seq_item)
    `uvm_field_int (reset      , UVM_DEFAULT)
    
    `uvm_field_int (instrf     , UVM_DEFAULT)
    `uvm_field_int (pcf        , UVM_DEFAULT)
    `uvm_field_int (readdatam  , UVM_DEFAULT)
    
    `uvm_field_int (writedatam , UVM_DEFAULT)
    `uvm_field_int (dataadrm   , UVM_DEFAULT)
    `uvm_field_int (memwritem  , UVM_DEFAULT)
     
    `uvm_field_int (lwstall    , UVM_DEFAULT)
    `uvm_field_int (beqflush   , UVM_DEFAULT)
    `uvm_field_enum(instr_type , inst_type , UVM_DEFAULT) 
  `uvm_object_utils_end
  
  constraint opcode_range {
    instrf [6 : 0] inside {
      lw, imm,
      auipc, sw,
      arith, lui,
      brnch, jalr,
      jal
    };
  };
  
  // Constraints for opcode_dist
  constraint funct_range {
    (instrf[6:0] == lw) -> (instrf[14:12] == 3'b010);
    
    ((instrf[6:0] == imm) && (instrf[14:12] == 3'b101)) -> (instrf[31:25] inside {7'b0000000, 7'b0100000});
    
    ((instrf[6:0] == imm) && (instrf[14:12] == 3'b001)) -> (instrf[31:25] == 7'b0000000);
    
    (instrf[6:0] == imm) -> (instrf[14:12] != 3'b011);
    
    (instrf[6:0] == sw) -> (instrf[14:12] == 3'b010);
    
    (instrf[6:0] == arith) -> (instrf[14:12] inside {add, sll, slt, Xor, srl, Or, And});
    
    ((instrf[6:0] == arith) && (instrf[14:12] == add)) -> (instrf[31:25] inside {7'b0000000, 7'b0100000});
    
    ((instrf[6:0] == arith) && (instrf[14:12]==sll || instrf[14:12]==slt || instrf[14:12]==Xor || instrf[14:12]==Or || instrf[14:12]==And )) -> (instrf[31:25] == 7'b0000000);
    
    ((instrf[6:0] == arith) && (instrf[14:12] == sra)) -> (instrf[31:25] inside {7'b0100000, 7'b0000000});
    
    (instrf[6:0] == brnch) -> (instrf[14:12] inside {beq, bne, blt, bge});
    
    (instrf[6:0] == jalr) -> (instrf[14:12] == 3'b000);
    
    ((instrf[6:0] != sw) && (instrf[6:0] != brnch)) -> (instrf[11:7] != 0) ;
  };  
  
  // Distribution "reset" distribution 
  constraint reset_dist {
    reset dist{
      1 := 1 , 0 := 100000
    }; 
  }; 
  
  // reset function
  function void Reset();
    instrf     = 32'b0;
    pcf        = 32'b0;
    
    writedatam = 32'b0;
    dataadrm   = 32'b0;
    memwritem  = 1'b0;
        
    lwstall    = 1'b0;
    beqflush   = 1'b0;
    inst_type  = RESET;
  endfunction
  
  // Get instruction type function
  function Get_type ;
    case (instrf[6:0])  

      lw    : inst_type = LW;
      sw    : inst_type = SW;
      lui   : inst_type = LUI;
      auipc : inst_type = AUIPC;
      jalr  : inst_type = JALR;
      jal   : inst_type = JAL;

      imm   : begin 
        case(instrf[14:12])     
          3'b000 : inst_type = ADDI;
          3'b001 : inst_type = SLLI;
          3'b010 : inst_type = SLTI;
          3'b100 : inst_type = XORI;
          3'b110 : inst_type = ORI; 
          3'b111 : inst_type = ANDI;    
          3'b101 : begin 
            if (instrf[30] == 0) inst_type = SRLI;
            else inst_type = SRAI;
          end
        endcase 
      end

      arith : begin 
        case(instrf[14:12])     
          3'b001 : inst_type = SLL;
          3'b010 : inst_type = SLT;
          3'b100 : inst_type = XOR;
          3'b110 : inst_type = OR; 
          3'b111 : inst_type = AND;   
          3'b000 : begin 
            if (instrf[30] == 0) inst_type = ADD;
            else inst_type = SUB;
          end
          3'b101 : begin 
            if (instrf[30] == 0) inst_type = SRL;
            else inst_type = SRA;
          end  
        endcase   
      end

      brnch : begin 
        case(instrf[14:12])     
          3'b000 : inst_type = BEQ;
          3'b001 : inst_type = BNE;
          3'b100 : inst_type = BLT;
          3'b101 : inst_type = BGE;     
        endcase 
      end
           
      default : inst_type = UNKNOWN;
         
    endcase 

  endfunction

  // Extend immediate function
  function [31:0] Extend ;
    case(instrf[6:0])
      imm, lw, jalr : Extend = {{20{instrf[31]}}, instrf[31:20]};
		
      sw : Extend = {{20{instrf[31]}}, instrf[31:25], instrf[11:7]};
		
      brnch : Extend = {{20{instrf[31]}}, instrf[7], instrf[30:25], instrf[11:8], 1'b0};
		
      jal : Extend = {{12{instrf[31]}}, instrf[19:12], instrf[20], instrf[30:21], 1'b0};
		
      lui, auipc : Extend = {instrf[31:12], 12'b0};
		
      default: Extend = 32'bx; 
	endcase  
  endfunction
  
endclass