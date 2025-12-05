module controller(
  input        clk,
  input        reset,
  
  input  [6:0] op,
  
  input  [2:0] funct3d,
  input        funct7b5,
  
  input        zeroe,
  input        signe,
  
  input        flushe,
  
  output       resultsrce0,
  output [1:0] resultsrcw,
  
  output       memwritem,
  
  output       pcjalsrce,
  output       pcsrce,
  
  output       alusrcae,
  output [1:0] alusrcbe,
  
  output       regwritem,
  output       regwritew,
  
  output [2:0] immsrcd,
  
  output [3:0] alucontrole
);

  wire [1:0] aluopd;
  wire [1:0] resultsrcd, resultsrce, resultsrcm;
  wire [3:0] alucontrold;
  wire       branchd, branche, memwrited, memwritee, jumpd, jumpe;
  wire       alusrcad, regwrited, regwritee;
  wire [1:0] alusrcbd;
  wire       zeroop, signop, branchop;
  wire [2:0] funct3e;

  maindec md (
    .op         (op),
    
    .regwrite   (regwrited),
    .resultsrc  (resultsrcd),
    
    .memwrite   (memwrited),
    .branch     (branchd),
    
    .alusrca    (alusrcad),
    .alusrcb    (alusrcbd),
    
    .jump       (jumpd),
    .immsrc     (immsrcd),
    
    .aluop      (aluopd)
  );

  aludec ad (
    .opb5       (op[5]),
    .funct3     (funct3d),
    .funct7b5   (funct7b5),
    .aluop      (aluopd),
    .alucontrol (alucontrold)
  );

  c_id_iex pipreg_d_to_e (
    .clk         (clk),
    .reset       (reset),
    .clear       (flushe),
    
    .regwrited   (regwrited),
    .memwrited   (memwrited),
    
    .jumpd       (jumpd),
    .branchd     (branchd),
    
    .alusrcad    (alusrcad),
    .alusrcbd    (alusrcbd),
    
    .resultsrcd  (resultsrcd),
    
    .alucontrold (alucontrold),
    .funct3d     (funct3d), 
    
    .regwritee   (regwritee),
    .memwritee   (memwritee),
    
    .jumpe       (jumpe),
    .branche     (branche),
    
    .alusrcae    (alusrcae),
    .alusrcbe    (alusrcbe),
    
    .resultsrce  (resultsrce),
    
    .alucontrole (alucontrole),
    .funct3e     (funct3e) 
  );

  c_iex_im pipreg_e_to_m (
    .clk         (clk),
    .reset       (reset),
    
    .regwritee   (regwritee),
    .memwritee   (memwritee),
    .resultsrce  (resultsrce),
    
    .regwritem   (regwritem),
    .memwritem   (memwritem),
    .resultsrcm  (resultsrcm)
  );

  c_im_iw pipreg_m_to_w (
    .clk         (clk),
    .reset       (reset),
    
    .regwritem   (regwritem),
    .resultsrcm  (resultsrcm),
    
    .regwritew   (regwritew),
    .resultsrcw  (resultsrcw)
  );

  assign resultsrce0  = resultsrce[0];
  assign zeroop       = zeroe ^ funct3d[0];
  assign signop       = signe ^ funct3d[0];
  assign branchop     = funct3d[2] ? signop : zeroop;
  assign pcsrce       = (branche & branchop) | jumpe;
  assign pcjalsrce    = (op == 7'b1100111) ? 1'b1 : 1'b0;

endmodule
