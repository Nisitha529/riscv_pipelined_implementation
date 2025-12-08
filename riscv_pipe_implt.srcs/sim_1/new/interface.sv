interface intf ( input logic clk);

  import risc_pkg::* ;
  
  logic reset;
  
  logic [31 : 0] instrf;
  logic [31 : 0] pcf;
  logic [31 : 0] readdatam;
  
  logic [31 : 0] writedatam;
  logic [31 : 0] dataadrm;
  logic          memwritem;
  
  instr_type     inst_type;

endinterface
