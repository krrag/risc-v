`timescale 1ns/1ps

module tb_buttons;
  reg         clk_i;
  reg         rst_ni;
  reg         en_i;
  reg [31:0]  addr_i;
  reg [ 9:0]  push_i;
  reg [ 7:0]  switch_i;
  reg [31:0]  rdata_o;

  // Instantiate design and connect design ports with TB signals
  buttons uut ( .clk_i      (clk_i),
                .rst_ni     (rst_ni),
                .en_i       (en_i),
                .addr_i     (addr_i),
                .push_i     (push_i),
                .switch_i   (switch_i),
                .rdata_o    (rdata_o)
            );

  clock #(.FREQ(800000)) u1(.enable_i(enable_clk), .clk_o(clk_i));

  //Testbench variables
  integer i; //Test number
  reg enable_clk; //Activate clock

  // Helper task for checking results
  reg test_failed;
  integer test_case;
  task static check_output;
    input [ 9:0] expected_buttons;
    input [ 7:0] expected_switch;
    begin
      reg [ 9:0] last_buttons;
      reg [ 7:0] last_switch;
      if (!en_i) begin
        expected_buttons = last_buttons;
        expected_switch = last_switch;
      end else begin
        last_buttons = expected_buttons;
        last_switch = expected_switch;
      end
      if ((rdata_o[9:0] != expected_buttons) || (rdata_o[23:16] != expected_switch)) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  Expected buttons: 0x%h | Got 0x%h", expected_buttons, rdata_o[9:0]);
        $display("  Expected switch:  0x%h | Got 0x%h", expected_switch, rdata_o[23:16]);
        test_failed = 1;
      end
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
    $dumpfile("dump/tb_buttons.vcd");
    $dumpvars(0, tb_buttons);

    // 1. Initialize testbench variables
    en_i = 0;
    enable_clk = 0;

    // 2. Enable clock and init
    #5
    enable_clk = 1;
    @(negedge clk_i)
    en_i = 1;
    addr_i = 32'h70000000;

    for (i = 0; i < 50000; i = i + 1) begin
      push_i = random()[9:0];
      switch_i = random()[7:0];
      en_i = random()[0];
      @(negedge clk_i)
      check_output(push_i, switch_i);
    end
    $finish;
  end
endmodule
