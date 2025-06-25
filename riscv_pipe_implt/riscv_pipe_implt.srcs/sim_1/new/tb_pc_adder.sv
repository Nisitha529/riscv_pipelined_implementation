`timescale 1ns / 1ps

module tb_pc_adder();

    // Test parameters
    parameter NUM_TESTS = 100;
    parameter CLK_PERIOD = 10;  // 100 MHz clock
    
    // DUT signals
    logic [31:0] a;
    logic [31:0] b;
    logic [31:0] c;
    
    // Testbench signals
    logic [31:0] expected_c;
    int error_count;
    logic clk;
    
    // Instantiate DUT
    pc_adder dut (
        .a(a),
        .b(b),
        .c(c)
    );
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Main test sequence
    initial begin
        // Initialize
        error_count = 0;
        a = 32'h0;
        b = 32'h0;
        
        $display("\nStarting PC Adder Testbench\n");
        $timeformat(-9, 2, " ns", 10);
        
        // Test Case 1: Basic additions
        $display("[TEST 1] Basic additions");
        test_addition(32'h00000000, 32'h00000000, 32'h00000000, "0 + 0");
        test_addition(32'h00000001, 32'h00000001, 32'h00000002, "1 + 1");
        test_addition(32'h0000000A, 32'h00000005, 32'h0000000F, "10 + 5");
        test_addition(32'h0000FFFF, 32'h00000001, 32'h00010000, "65535 + 1");
        
        // Test Case 2: Boundary values
        $display("\n[TEST 2] Boundary values");
        test_addition(32'h7FFFFFFF, 32'h00000001, 32'h80000000, "Max positive + 1");
        test_addition(32'h80000000, 32'hFFFFFFFF, 32'h7FFFFFFF, "Min negative + -1");
        test_addition(32'hFFFFFFFF, 32'h00000001, 32'h00000000, "Max unsigned + 1");
        test_addition(32'hFFFFFFFF, 32'hFFFFFFFF, 32'hFFFFFFFE, "Max unsigned + Max unsigned");
        
        // Test Case 3: Signed number additions
        $display("\n[TEST 3] Signed number additions");
        test_addition(32'hFFFFFFFE, 32'h00000002, 32'h00000000, "-2 + 2");
        test_addition(32'hFFFFFFF0, 32'h00000020, 32'h00000010, "-16 + 32");
        test_addition(32'h80000000, 32'h7FFFFFFF, 32'hFFFFFFFF, "Min signed + Max signed");
        test_addition(32'hC0000000, 32'hC0000000, 32'h80000000, "-1073741824 + -1073741824");
        
        // Test Case 4: Random additions
        $display("\n[TEST 4] Random additions (%0d tests)", NUM_TESTS);
        for (int i = 0; i < NUM_TESTS; i++) begin
            logic [31:0] rand_a = $urandom();
            logic [31:0] rand_b = $urandom();
            logic [31:0] rand_sum = rand_a + rand_b;
            
            a = rand_a;
            b = rand_b;
            #10;
            
            if (c !== rand_sum) begin
                $display("  FAIL[%0d]: %h + %h = %h (Expected %h)", 
                         i, a, b, c, rand_sum);
                error_count++;
            end
            else begin
                $display("  PASS[%0d]: %h + %h = %h", i, a, b, c);
            end
        end
        
        // Test Case 5: Timing checks
        $display("\n[TEST 5] Timing checks");
        a = 32'h12345678;
        b = 32'h9ABCDEF0;
        #1; // Check propagation delay
        if (c === 32'bx) $display("  PASS: Output not ready at 1ns");
        else $display("  WARNING: Output ready too fast at 1ns");
        
        #(CLK_PERIOD - 1);
        if (c === (32'h12345678 + 32'h9ABCDEF0)) 
            $display("  PASS: Output stable before clock period");
        else
            $display("  FAIL: Output incorrect at %t", $time);
        
        // Summary
        $display("\n\nTest Summary:");
        $display("  Passed tests: %0d", (4 + 4 + 4 + NUM_TESTS + 2) - error_count);
        $display("  Failed tests: %0d", error_count);
        $display("\nSimulation %s", (error_count ? "FAILED" : "PASSED"));
        $finish;
    end
    
    // Test task
    task test_addition(input [31:0] a_val, b_val, exp_val, input string test_name);
        a = a_val;
        b = b_val;
        #10;  // Allow time for calculation
        
        if (c === exp_val) begin
            $display("  PASS: %-20s %h + %h = %h", test_name, a, b, c);
        end else begin
            $display("  FAIL: %-20s %h + %h = %h (Expected %h)", test_name, a, b, c, exp_val);
            error_count++;
        end
    endtask
    
    // Waveform dumping
    initial begin
        $dumpfile("tb_pc_adder.vcd");
        $dumpvars(0, tb_pc_adder);
    end
    
endmodule