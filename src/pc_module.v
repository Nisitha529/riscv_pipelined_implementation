module pc_module (
    input  wire        clk,      // System clock
    input  wire        rst,      // Active-low synchronous reset
    input  wire [31:0] pc_next,  // Next PC value
    output reg  [31:0] pc        // Current PC value
);

    // Program Counter register
    always @(posedge clk) begin
        if (rst)  pc <= 32'h0;   // Synchronous reset
        else      pc <= pc_next; // Normal operation
    end

endmodule