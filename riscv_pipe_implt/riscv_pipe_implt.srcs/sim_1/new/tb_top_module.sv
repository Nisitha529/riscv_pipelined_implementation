`timescale 1ns/1ps

module top_module_tb;

  // Clock and reset signals
  logic clk;
  logic reset;

  // DUT signals
  logic [31:0] pcf;
  logic [31:0] instrf;
  logic memwritem;
  logic [31:0] dataadrm, writedatam, readdatam;

  // Instantiate DUT
  top_module DUT (
    .clk(clk),
    .reset(reset),
    .instrf(instrf),
    .pcf(pcf),
    .readdatam(readdatam),
    .writedatam(writedatam),
    .dataadrm(dataadrm),
    .memwritem(memwritem)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Test program memory (instructions)
  logic [31:0] test_program [0:15] = '{
    32'h00f00093,  // ADDI x1, x0, 7
    32'h01600113,  // ADDI x2, x0, 22
    32'h002081b3,  // ADD x3, x1, x2
    32'h0021e233,  // OR x4, x3, x2
    32'h0041c2b3,  // XOR x5, x3, x4
    32'h00428333,  // SUB x6, x5, x4
    32'h02628863,  // BEQ x5, x6, 16
    32'h0041a233,  // SLT x4, x3, x4
    32'h00020463,  // BEQ x4, x0, 8
    32'h00000313,  // ADDI x6, x0, 0
    32'h0032a233,  // SLT x4, x5, x3
    32'h00520333,  // ADD x6, x4, x5
    32'h40118133,  // SUB x2, x3, x1
    32'h0411aa23,  // SW x1, 84(x3)
    32'h0541a083,  // LW x1, 84(x3)
    32'h00008093   // ADDI x1, x1, 0
  };

  // Expected memory writes
  typedef struct {
    logic [31:0] addr;
    logic [31:0] data;
  } mem_check_t;

  mem_check_t expected_writes[$] = '{'{113, 32'd7}};

  // Instruction fetch logic
  always @(posedge clk) begin
    if (!reset) begin
      if (pcf[31:2] < 16)
        instrf <= test_program[pcf[31:2]];
      else
        instrf <= 32'h00000013; // NOP if PC out of range
    end else begin
      instrf <= 32'h00000013; // NOP during reset
    end
  end

  // Test control variables
  int cycle_count = 0;
  int error_count = 0;
  logic test_complete = 0;

  initial begin
    clk = 0;
    reset = 1;

    $dumpfile("top_module_sim.vcd");
    $dumpvars(0, top_module_tb);

    $display("==============================================");
    $display(" Top Module Self-Checking Testbench");
    $display("==============================================");

    #20 reset = 0;
    $display("Reset released at %0t", $time);

    while (!test_complete && cycle_count < 100) begin
      @(posedge clk);
      cycle_count++;

      $display("Cycle %2d: PC=0x%08h Instr=0x%08h MemWrite=%b Addr=0x%08h Data=0x%08h", 
                cycle_count, pcf, instrf, memwritem, dataadrm, writedatam);

      // Check memory writes
      if (memwritem) begin
        int found = 0;
        foreach (expected_writes[i]) begin
          if (dataadrm == expected_writes[i].addr) begin
            found = 1;
            if (writedatam !== expected_writes[i].data) begin
              $error("ERROR: At addr 0x%08h wrote 0x%08h, expected 0x%08h", dataadrm, writedatam, expected_writes[i].data);
              error_count++;
            end else begin
              $display("  PASS: Memory write matches expected data at 0x%08h", dataadrm);
              expected_writes.delete(i); // remove verified entry
            end
            break;
          end
        end
        if (!found) begin
          $error("ERROR: Unexpected memory write to 0x%08h with data 0x%08h", dataadrm, writedatam);
          error_count++;
        end
      end

      // End test if program counter reaches after last instruction
      if (pcf == 32'h0000003C) begin
        test_complete = 1;
        $display("Program completed at cycle %0d", cycle_count);
      end
    end

    // Check for any missing expected writes
    if (expected_writes.size() > 0) begin
      $error("ERROR: %0d expected memory writes did not occur", expected_writes.size());
      foreach(expected_writes[i]) begin
        $error("  Missing write Addr=0x%08h Data=0x%08h", expected_writes[i].addr, expected_writes[i].data);
      end
      error_count += expected_writes.size();
    end

    $display("\n======== TEST SUMMARY ========");
    $display("Total cycles: %0d", cycle_count);
    $display("Errors found: %0d", error_count);
    if (error_count == 0) 
      $display("STATUS: ALL TESTS PASSED");
    else
      $display("STATUS: TEST FAILURES");
    $display("=============================");

    $finish;
  end

endmodule
