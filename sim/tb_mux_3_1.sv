`timescale 1ns/1ps

module tb_mux_3_by_1;
    // Inputs
    reg [31:0] a, b, c;
    reg [1:0] s;
    // Output
    wire [31:0] d;
    
    // Instantiate DUT
    mux_3_1 dut (
        .a(a),
        .b(b),
        .c(c),
        .s(s),
        .d(d)
    );
    
    // Test parameters
    parameter NUM_RANDOM_TESTS = 25;
    
    initial begin
        $timeformat(-9, 2, " ns", 10);
        $display("Starting 3-to-1 Mux testbench...\n");
        
        // Test Case 1: Basic functionality - select each input
        $display("[Test 1] Basic functionality");
        a = 32'hAAAA_AAAA;
        b = 32'hBBBB_BBBB;
        c = 32'hCCCC_CCCC;
        
        s = 2'b00;  // Select a
        #10 check_output("Select A");
        
        s = 2'b01;  // Select b
        #10 check_output("Select B");
        
        s = 2'b10;  // Select c
        #10 check_output("Select C");
        
        s = 2'b11;  // Select default
        #10 check_output("Select default (0)");
        
        // Test Case 2: Edge values
        $display("\n[Test 2] Edge value testing");
        test_edge_values(32'h0000_0000, 32'h0000_0000, 32'h0000_0000, "All zeros");
        test_edge_values(32'hFFFF_FFFF, 32'hFFFF_FFFF, 32'hFFFF_FFFF, "All ones");
        test_edge_values(32'hAAAA_AAAA, 32'h5555_5555, 32'hCCCC_CCCC, "Alternating patterns");
        test_edge_values(32'h1234_5678, 32'h9ABC_DEF0, 32'hFEDC_BA98, "Mixed values");
        
        // Test Case 3: Randomized testing
        $display("\n[Test 3] Randomized testing (%0d cycles)", NUM_RANDOM_TESTS);
        for (int i = 0; i < NUM_RANDOM_TESTS; i++) begin
            a = $urandom();
            b = $urandom();
            c = $urandom();
            s = $urandom_range(0, 3);  // 0-3 inclusive
            
            #5 check_output($sformatf("Random test #%0d", i+1));
        end
        
        // Test Case 4: Timing checks
        $display("\n[Test 4] Timing checks");
        a = 32'h1111_1111;
        b = 32'h2222_2222;
        c = 32'h3333_3333;
        
        s = 2'b00;
        #1;
        if (d !== a) $display("Error! Propagation delay too long at T=%t", $time);
        
        s = 2'b01;
        #0.5;
        if (d !== b) $display("Error! Output should stabilize within 0.5ns at T=%t", $time);
        
        // Test Case 5: Simultaneous input changes
        $display("\n[Test 5] Simultaneous input changes");
        s = 2'b10;
        #5;
        {a, b, c} = {32'hDEAD_BEEF, 32'hCAFE_BABE, 32'hFACEB00C};
        #1 check_output("Simultaneous input change");
        
        // Test Case 6: X-handling (if simulator supports)
        $display("\n[Test 6] Unknown state handling");
        s = 2'b00;
        a = 32'hXXXXXXXX;
        #10 $display("T=%t: Output with X inputs: d=%h", $time, d);
        
        s = 2'b11;
        #10 $display("T=%t: Default selection with X inputs: d=%h", $time, d);
        
        $display("\nAll tests completed!");
        $finish;
    end
    
    // Task to test edge values for all selection cases
    task automatic test_edge_values(
        input [31:0] a_val, 
        input [31:0] b_val, 
        input [31:0] c_val,
        input string test_name
    );
        a = a_val;
        b = b_val;
        c = c_val;
        
        s = 2'b00;
        #5 check_output({test_name, " (s=00)"});
        
        s = 2'b01;
        #5 check_output({test_name, " (s=01)"});
        
        s = 2'b10;
        #5 check_output({test_name, " (s=10)"});
        
        s = 2'b11;
        #5 check_output({test_name, " (s=11)"});
    endtask
    
    // Self-checking task
    task automatic check_output(input string testname);
        logic [31:0] expected;
        
        case(s)
            2'b00: expected = a;
            2'b01: expected = b;
            2'b10: expected = c;
            default: expected = 32'h00000000;  // s=11
        endcase
        
        if (d === expected) begin
            $display("T=%t: [PASS] %-25s s=%b => d=%h (Expected: %h)", 
                     $time, testname, s, d, expected);
        end else begin
            $display("T=%t: [FAIL] %-25s s=%b => d=%h (Expected: %h)", 
                     $time, testname, s, d, expected);
        end
    endtask
endmodule