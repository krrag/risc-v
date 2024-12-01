`timescale 1ns/1ps

module tb_mem;
  reg         clk_i;
  reg         en_i;
  reg         we_i;
  reg [31:0]  addr_i;
  reg [31:0]  wdata_i;
  reg [31:0]  rdata_o;

  // Instantiate design and connect design ports with TB signals
  mem #(
      .B(32'hA0000000)
  ) uut (   .clk_i    (clk_i),
            .en_i     (en_i),
            .we_i     (we_i),
            .addr_i   (addr_i),
            .wdata_i  (wdata_i),
            .rdata_o  (rdata_o)
            );

  //Testbench variables
  integer i; //Test number
  reg enable_clk; //Activate clock
  integer addr, val;

  clock #(.FREQ(800000)) u1(.enable_i(enable_clk), .clk_o(clk_i));

  // Helper task for checking results
  reg test_failed;
  integer test_case;
  task static mem_test;
    input [31:0] addr;
    input [31:0] expected_val;
    begin
      if (addr <= 32'h80000000 || addr >= 32'h9FFFFFFF || addr[1:0] != 0) begin
        expected_val = 0;
      end else begin
        if (uut.mem_r[addr] !== expected_val) begin
          $display("Error in test case %0d at time %0t:", test_case, $time);
          $display("  At adress: 0x%h", addr);
          $display("  Expected val: 0x%h", expected_val);
          $display("  Got      val: 0x%h", uut.mem_r[addr]);
          test_failed = 1;
        end
      end
      test_case = test_case + 1;

      we_i = 0;
      addr_i = addr;
      @(negedge clk_i)
      if (rdata_o !== expected_val) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  At adress: 0x%h", addr);
        $display("  Expected val: 0x%h", expected_val);
        $display("  Got      val: 0x%h", rdata_o);
        test_failed = 1;
      end
      we_i = 1;
      test_case = test_case + 1;
    end
  endtask

  function static [31:0] random;
    begin
      random = $urandom;
    end
  endfunction

  // This initial block forms the stimulus to test the design
  initial begin
    // Generate waveform file
    $dumpfile("dump/tb_mem.vcd");
    $dumpvars(0, tb_mem);

    // 1. Initialize testbench variables
    en_i = 0;
    enable_clk = 0;

    // 2. Enable clock
    #5
    enable_clk = 1;
    @(negedge clk_i)
    en_i = 1;
    we_i = 1;

    for (i = 0; i < 5000; i = i + 1) begin
      addr = random();
      val = random();
      wdata_i = val;
      addr_i = addr;
      mem_test(addr, val);
    end
    $finish;
  end
endmodule
