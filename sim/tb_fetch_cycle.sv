`timescale 1ns/1ps

module tb_fetch_cycle();
    // Inputs
    logic        clk;
    logic        rst;         // Active-low synchronous reset
    logic        pcsrc_e;
    logic [31:0] pctarget_e;
    
    // Outputs
    wire [31:0] instr_d;
    wire [31:0] pc_d;
    wire [31:0] pcplus4_d;
    
    // Instantiate DUT
    fetch_cycle dut (
        .clk(clk),
        .rst(rst),
        .pcsrc_e(pcsrc_e),
        .pctarget_e(pctarget_e),
        .instr_d(instr_d),
        .pc_d(pc_d),
        .pcplus4_d(pcplus4_d)
    );
    
    // Clock generation (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Main test sequence
    initial begin
        // Initialize signals
        rst = 0;           // Assert reset (active-low)
        pcsrc_e = 0;
        pctarget_e = 0;
        
        // Reset sequence
        #10 rst = 1;       // Deassert reset after 10ns
        
        // Test 1: Sequential execution (PC+4)
        $display("\n[Test 1] Sequential execution");
        #20;  // Wait for 2 clock cycles
        
        // Test 2: Branch redirection
        $display("\n[Test 2] Branch redirection");
        @(posedge clk);
        pcsrc_e = 1;
        pctarget_e = 32'h0000_0010;
        @(posedge clk);
        pcsrc_e = 0;
        
        // Test 3: Reset during operation
        $display("\n[Test 3] Reset assertion");
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        rst = 1;
        
        // Test 4: Post-reset behavior
        $display("\n[Test 4] Post-reset execution");
        repeat(2) @(posedge clk);
        
        #20 $display("\nAll tests completed");
        $finish;
    end
    
    // Monitoring and verification
    always @(posedge clk) begin
        $display("Time %0t: PC=0x%8h, PC+4=0x%8h, Instr=0x%8h, Branch=%b, Target=0x%8h",
                 $time, pc_d, pcplus4_d, instr_d, pcsrc_e, pctarget_e);
                
        // Reset state verification
        if (rst === 0) begin
            if (instr_d !== 0 || pc_d !== 0 || pcplus4_d !== 0) begin
                $error("Reset failed: Outputs not zero");
            end
        end
    end
    
    // PC sequence verification
    logic [31:0] expected_pc;
    always @(posedge clk) begin
        if (rst) begin
            if (pcsrc_e) begin
                expected_pc <= pctarget_e;
            end else begin
                expected_pc <= pc_d + 4;
            end
            
            // Verify PC propagation
            if (pc_d !== expected_pc && $time > 20) begin
                $error("PC mismatch! Expected: 0x%8h, Got: 0x%8h", expected_pc, pc_d);
            end
        end
    end
endmodule