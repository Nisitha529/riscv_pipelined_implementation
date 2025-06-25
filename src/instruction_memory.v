module instruction_memory #(
  parameter MEM_FILE = "memfile.hex"
)(
    input        rst,
    input [31:0] a,
    output [31:0] rd
);

    reg [31:0] mem [0:1023];
    
    assign rd = (rst) ? 32'h0 : mem[a[31:2]];
    
    initial begin
        $readmemh(MEM_FILE, mem);
    end
endmodule