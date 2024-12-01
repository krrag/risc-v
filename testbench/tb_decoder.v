`timescale 1ns/1ps

module tb_decoder;
  reg [31:0]  addr_i;
  reg         en_ram_o;
  reg         en_leds_o;
  reg         en_7_seg_lcd_o;
  reg         en_buttons_o;

  // Instantiate design and connect design ports with TB signals
  decoder uut ( .addr_i         (addr_i),
                .en_ram_o       (en_ram_o),
                .en_leds_o      (en_leds_o),
                .en_7_seg_lcd_o (en_7_seg_lcd_o),
                .en_buttons_o   (en_buttons_o)
            );

  //Testbench variables
  integer i; //Test number

  // Helper task for checking results
  reg test_failed;
  integer test_case;
  task static check_output;
    input [31:0] addr;
    begin
      reg expected_led_o;
      reg expected_seg_o;
      reg expected_butt_o;
      reg expected_ram_o;
      addr_i = addr;
      #1;
      expected_led_o = 0;
      expected_seg_o = 0;
      expected_butt_o = 0;
      expected_ram_o = 0;
      if (addr >= 32'h50000000 && addr <= 32'h50000FFF) begin
        expected_led_o = 1;
      end else if (addr >= 32'h60000000 && addr <= 32'h60000FFF) begin
        expected_seg_o = 1;
      end else if (addr >= 32'h70000000 && addr <= 32'h50000FFF) begin
        expected_butt_o = 1;
      end else if (addr >= 32'h80000000 && addr <= 32'h9FFFFFFF) begin
        expected_ram_o = 1;
      end
      if ((uut.en_ram_o !== expected_ram_o) || (uut.en_leds_o !== expected_led_o) ||
          (uut.en_7_seg_lcd_o !== expected_seg_o) || (uut.en_buttons_o !== expected_butt_o)) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  At adress: 0x%h", addr);
        $display("  Expected ram_o: 0x%h | Got 0x%h", expected_ram_o, uut.en_ram_o);
        $display("  Expected led_o: 0x%h | Got 0x%h", expected_led_o, uut.en_leds_o);
        $display("  Expected lcd_o: 0x%h | Got 0x%h", expected_seg_o, uut.en_7_seg_lcd_o);
        $display("  Expected but_o: 0x%h | Got 0x%h", expected_butt_o, uut.en_buttons_o);
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
    $dumpfile("dump/tb_decoder.vcd");
    $dumpvars(0, tb_decoder);

    for (i = 0; i < 50000; i = i + 1) begin
      check_output(random());
    end
    $finish;
  end
endmodule
