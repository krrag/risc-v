//Modified version from https://www.chipverify.com/verilog/verilog-d-latch
`timescale 1ns/1ps

module tb_ir;
  // Declare variables that can be used to drive values to the design
  reg        clk_i;
  reg        enable_i;
  reg        enable_clk;
  reg [31:0] d_i;
  reg [31:0] q_o;
  reg [ 2:0] delay;
  reg [ 1:0] delay2;
  integer i;

  // Instantiate design and connect design ports with TB signals
  ir  uut ( .clk_i      (clk_i),
            .d_i        (d_i),
            .enable_i   (enable_i),
            .q_o        (q_o));

  clock #(.FREQ(800000)) u1(.enable_i(enable_clk), .clk_o(clk_i));

  function static [31:0] random;
    begin
      random = $urandom;
    end
  endfunction

  // This initial block forms the stimulus to test the design
  initial begin
    // Generate waveform file
    $dumpfile("dump/tb_ir.vcd");
    $dumpvars(0, tb_ir);
    $monitor ("[%0t] en=%0b d=%0b q=%0b", $time, enable_i, d_i, q_o);

    // 1. Initialize testbench variables
    d_i = 0;
    enable_i = 0;
    enable_clk = 0;

    // 2. Wait for signal to settle
    #5
    enable_clk = 1;
    #5

    // 3. Randomly change d and enable
    for (i = 0; i < 10; i=i+1) begin
      delay = random()[2:0];
      delay2 = random()[1:0];
      #(delay2) enable_i = ~enable_i;
      #(delay) d_i = random();
    end

    $finish;
  end
endmodule
