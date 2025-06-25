`timescale 1ns / 1ps

module tb_instruction_memory();

    // Parameters
    parameter CLK_PERIOD = 10;  // 100 MHz clock
    
    // DUT signals
    logic        rst;
    logic [31:0] a;
    logic [31:0] rd;
    
    // Testbench signals
    int error_count;
    
    // Instantiate DUT
    instruction_memory dut (
        .rst(rst),
        .a(a),
        .rd(rd)
    );
    
    // Initialize memory with test content
    initial begin
        // Initialize memory directly
        for (int i = 0; i < 1024; i++) begin
            if (i < 16) begin
                // First 16 locations: 0x00000000 to 0xFFFFFFFF in steps
                dut.mem[i] = i * 32'h11111111;
            end
            else begin
                // Other locations: set to zero
                dut.mem[i] = 32'h0;
            end
        end
        
        // Set last memory location
        dut.mem[1023] = 32'hFFFFFFFF;
    end
    
    // Test cases
    initial begin
        // Initialize
        error_count = 0;
        rst = 1'b0;
        a = 32'h0;
        
        $display("\nStarting Instruction Memory Testbench\n");
        $timeformat(-9, 2, " ns", 10);
        
        // Test Case 1: Reset behavior
        $display("[TEST 1] Reset behavior");
        rst = 1'b0;
        #10;
        check_output(32'h0, "Reset active");
        
        // Test Case 2: Basic reads
        $display("\n[TEST 2] Basic reads");
        rst = 1'b1;
        
        // Read address 0
        a = 32'h0;
        #10;
        check_output(32'h00000000, "Address 0x0");
        
        // Read address 4
        a = 32'h4;
        #10;
        check_output(32'h11111111, "Address 0x4");
        
        // Read address 8
        a = 32'h8;
        #10;
        check_output(32'h22222222, "Address 0x8");
        
        // Test Case 3: Address alignment
        $display("\n[TEST 3] Address alignment");
        a = 32'h1;  // Should still access word 0
        #10;
        check_output(32'h00000000, "Unaligned address 0x1");
        
        a = 32'h2;  // Should still access word 0
        #10;
        check_output(32'h00000000, "Unaligned address 0x2");
        
        a = 32'h3;  // Should still access word 0
        #10;
        check_output(32'h00000000, "Unaligned address 0x3");
        
        a = 32'h7;  // Should access word 1
        #10;
        check_output(32'h11111111, "Unaligned address 0x7");
        
        // Test Case 4: Boundary addresses
        $display("\n[TEST 4] Boundary addresses");
        // First address
        a = 32'h0;
        #10;
        check_output(32'h00000000, "First address");
        
        // Last valid address
        a = 32'h00000FFC;  // 1023 * 4
        #10;
        check_output(32'hFFFFFFFF, "Last valid address");
        
        // Test Case 5: Out-of-range addresses
        $display("\n[TEST 5] Out-of-range addresses");
        // Just beyond last address
        a = 32'h00001000;
        #10;
        $display("  Address 0x%0h: RD = 0x%0h (Unknown expected)", a, rd);
        
        // High address
        a = 32'hFFFF0000;
        #10;
        $display("  Address 0x%0h: RD = 0x%0h (Unknown expected)", a, rd);
        
        // Test Case 6: Reset during operation
        $display("\n[TEST 6] Reset during operation");
        a = 32'h4;
        #5;
        rst = 1'b0;
        #10;
        check_output(32'h0, "Reset during read");
        
        // Summary
        $display("\n\nTest Summary:");
        $display("  Passed tests: %0d", 10 - error_count);
        $display("  Failed tests: %0d", error_count);
        $display("\nSimulation %s", (error_count ? "FAILED" : "PASSED"));
        $finish;
    end
    
    // Output checking task
    task check_output(input [31:0] expected, input string test_name);
        if (rd === expected) begin
            $display("  PASS: %-20s RD = 0x%0h", test_name, rd);
        end else begin
            $display("  FAIL: %-20s Expected 0x%0h, Got 0x%0h", test_name, expected, rd);
            error_count++;
        end
    endtask
    
    // Waveform dumping
    initial begin
        $dumpfile("tb_instruction_memory.vcd");
        $dumpvars(0, tb_instruction_memory);
    end
    
endmodule