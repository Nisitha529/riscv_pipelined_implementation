`timescale 1ns / 1ps

module tb_pc_module();
    // Clock parameters
    parameter CLK_PERIOD = 10;  // 100 MHz clock

    // DUT signals
    logic        clk;       // System clock
    logic        rst;       // Active-low synchronous reset
    logic [31:0] pc_next;   // Next PC value
    logic [31:0] pc;        // Current PC value
    
    // Instantiate DUT
    pc_module dut (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Reset generation
    task apply_reset();
        rst = 1'b0;   // Assert reset
        @(posedge clk);
        #1;           // Offset from clock edge
        rst = 1'b1;   // Deassert reset
        @(posedge clk);
    endtask
    
    // Main test sequence
    initial begin
        // Initialize inputs
        rst = 1'b1;
        pc_next = '0;
        
        // Open simulation results file
        $timeformat(-9, 2, " ns", 10);
        $display("\nStarting PC Module Testbench\n");
        
        // Test Case 1: Power-on reset
        $display("[TEST 1] Power-on reset");
        apply_reset();
        #1;  // Wait for output update
        assert (pc === 32'h0) 
            else $error("Reset failed! PC = %0h", pc);
        $display("  PASS: Reset to 0x0 verified\n");
        
        // Test Case 2: Basic operation
        $display("[TEST 2] Basic operation");
        pc_next = 32'h0000_1000;
        @(posedge clk);
        #1;  // Wait for output update
        assert (pc === pc_next)
            else $error("PC update failed! Expected %0h, Got %0h", pc_next, pc);
        $display("  PASS: PC updated to 0x%0h\n", pc);
        
        // Test Case 3: Sequential updates
        $display("[TEST 3] Sequential updates");
        for (int i = 1; i <= 5; i++) begin
            pc_next = pc + 4;
            @(posedge clk);
            #1;  // Wait for output update
            assert (pc === pc_next)
                else $error("Update %0d failed! Expected %0h, Got %0h", i, pc_next, pc);
            $display("  PASS[%0d]: PC = 0x%0h", i, pc);
        end
        $display("");
        
        // Test Case 4: Reset during operation
        $display("[TEST 4] Reset during operation");
        pc_next = 32'hDEAD_BEEF;
        @(posedge clk);
        apply_reset();
        #1;  // Wait for output update
        assert (pc === 32'h0)
            else $error("Reset during operation failed! PC = %0h", pc);
        $display("  PASS: Reset during operation verified\n");
        
        // Test Case 5: Boundary values
        $display("[TEST 5] Boundary values");
        test_boundary(32'h0000_0000);
        test_boundary(32'hFFFF_FFFF);
        test_boundary(32'h8000_0000);
        test_boundary(32'h7FFF_FFFF);
        $display("");
        
        // Test Case 6: Random stimulus
        $display("[TEST 6] Random stimulus (10 cycles)");
        for (int i = 0; i < 10; i++) begin
            pc_next = $urandom();
            @(posedge clk);
            #1;  // Wait for output update
            assert (pc === pc_next)
                else $error("Random test %0d failed! Expected %0h, Got %0h", i, pc_next, pc);
            $display("  RAND[%0d]: PC = 0x%0h", i, pc);
        end
        $display("");
        
        // End simulation
        $display("\nAll tests passed successfully!");
        $finish;
    end
    
    // Task to test boundary values
    task test_boundary(input [31:0] value);
        pc_next = value;
        @(posedge clk);
        #1;  // Wait for output update
        assert (pc === value)
            else $error("Boundary test failed for 0x%0h! Got 0x%0h", value, pc);
        $display("  PASS: PC = 0x%0h", value);
    endtask
    
    // Coverage collection
    covergroup pc_cg @(posedge clk);
        reset_state: coverpoint rst {
            bins active_low = {0};
            bins inactive   = {1};
        }
        pc_value: coverpoint pc {
            bins zero    = {0};
            bins max     = {32'hFFFF_FFFF};
            bins min     = {32'h0000_0001};
            bins aligned = {[0:$]} with (item % 4 == 0);
            bins unaligned = {[0:$]} with (item % 4 != 0);
        }
        pc_transition: coverpoint pc {
            bins inc4 = (0 => 4);
        }
        reset_during_op: cross reset_state, pc_value {
            ignore_bins normal = binsof(reset_state) intersect {1};
        }
    endgroup
    
    initial begin
        pc_cg cg_inst = new();
    end
    
    // Waveform dumping
    initial begin
        $dumpfile("tb_pc_module.vcd");
        $dumpvars(0, tb_pc_module);
    end
endmodule