
module fetch_cycle  #(parameter MEM_FILE = "test_fetch_mem.hex")(
    input  wire        clk,        // System clock
    input  wire        rst,        // Active-low synchronous reset
    input  wire        pcsrc_e,    // PC selection control
    input  wire [31:0] pctarget_e, // Branch target address
    
    output wire [31:0] instr_d,    // Instruction output
    output wire [31:0] pc_d,       // PC output
    output wire [31:0] pcplus4_d   // PC+4 output
);

    // Internal signals
    reg  [31:0] pcf;        // Next PC value
    wire [31:0] pc_f;        // Current PC value
    wire [31:0] instr_f;     // Raw instruction from memory
    wire [31:0] pcplus4_f;   // PC+4 value

    // Pipeline registers
    reg [31:0] instr_reg;    // Instruction register
    reg [31:0] pc_reg;       // PC register
    reg [31:0] pcplus4_reg;  // PC+4 register

    // PC selection mux
    mux pc_mux (
        .a       (pcplus4_f),
        .b       (pctarget_e),
        .s       (pcsrc_e),
        .c       (pc_f)
    );

    // Program counter
    pc_module program_counter (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pcf),
        .pc      (pc_f)
    );

    // Instruction memory
    instruction_memory #(.MEM_FILE(MEM_FILE)) imem (
        .rst     (rst),
        .a       (pc_f),
        .rd      (instr_f)
    );

    // PC increment adder
    pc_adder pc_adder (
        .a       (pcf),
        .b       (32'h00000004),
        .c       (pcplus4_f)
    );

    // Pipeline register update
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset
            instr_reg   <= 32'h0;
            pc_reg      <= 32'h0;
            pcplus4_reg <= 32'h0;
            pcf         <= 32'h0;
        end
        else begin
            // Capture fetch stage values
            instr_reg   <= instr_f;
            pc_reg      <= pcf;
            pcf         <= pcplus4_f;
            pcplus4_reg <= pcplus4_f;
        end
    end

    // Output assignments
    assign instr_d   = (rst) ? 32'h0 : instr_reg;
    assign pc_d      = (rst) ? 32'h0 : pc_reg;
    assign pcplus4_d = (rst) ? 32'h0 : pcplus4_reg;

endmodule