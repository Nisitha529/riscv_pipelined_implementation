`timescale 1ns/1ps

module tb_mux;
    reg [31:0] a, b;
    reg s;
    wire [31:0] c;
    logic [31:0] expected;
    
    // Instantiate the MUX module
    mux dut (.a(a), .b(b), .s(s), .c(c));
    
    // Main test procedure
    initial begin
        $timeformat(-9, 2, " ns", 10);
        $display("\nStarting Mux testbench...");
        
        // Test 1: Basic functionality
        $display("\n[Test 1] Basic functionality");
        a = 32'h0000_0000;
        b = 32'hFFFF_FFFF;
        s = 0;
        #1 check_output("s=0");
        
        s = 1;
        #1 check_output("s=1");
        
        // Test 2: Edge values
        $display("\n[Test 2] Edge values");
        a = 32'h0000_0000;
        b = 32'hFFFF_FFFF;
        s = 0;
        #1 check_output("All zeros to all ones (s=0)");
        
        s = 1;
        #1 check_output("All zeros to all ones (s=1)");
        
        a = 32'hAAAA_AAAA;
        b = 32'h5555_5555;
        s = 0;
        #1 check_output("Alternating bits A (s=0)");
        
        s = 1;
        #1 check_output("Alternating bits 5 (s=1)");
        
        // Test 3: Randomized testing
        $display("\n[Test 3] Randomized testing (10 cycles)");
        for (int i = 0; i < 10; i++) begin
            a = $urandom();
            b = $urandom();
            s = $urandom_range(0,1);
            #1 check_output($sformatf("Random test #%0d", i));
        end
        
        // Test 4: Timing checks
        $display("\n[Test 4] Timing checks");
        a = 32'h0123_4567;
        b = 32'h89AB_CDEF;
        s = 0;
        #0; // Check propagation delay at time 0
        $display("T=%t: Checking propagation delay", $time);
        #0.5;
        if (c !== a) $display("Error! Output should stabilize within 0.5ns");
        
        // Finish simulation
        #10 $display("\nAll tests completed!");
        $finish;
    end
    
    // Self-checking task
    task automatic check_output(string testname);
        expected = s ? b : a;
        if (c === expected) begin
            $display("T=%t: [PASS] %s: a=%h b=%h s=%b c=%h",
                     $time, testname, a, b, s, c);
        end else begin
            $display("T=%t: [FAIL] %s: a=%h b=%h s=%b c=%h (Expected: %h)",
                     $time, testname, a, b, s, c, expected);
        end
    endtask
endmodule