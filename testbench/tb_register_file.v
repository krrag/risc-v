`timescale 1ns / 1ps

module tb_register_file ();
  // Inputs
  reg clk_i, wren_i;
  reg [ 4:0] aa_i, ab_i, aw_i;
  reg [31:0] wrdata_i;

  // Outputs
  wire [31:0] a_o, b_o;

  // Instantiate the Unit Under Test (UUT)
  register_file uut (
      .aa_i     (aa_i),
      .ab_i     (ab_i),
      .aw_i     (aw_i),
      .clk_i    (clk_i),
      .wren_i   (wren_i),
      .wrdata_i (wrdata_i),
      .a_o      (a_o),
      .b_o      (b_o)
  );

  // Variables for test tracking
  reg test_failed;
  integer test_case;
  integer register, val_to_write;
  integer expected_a, expected_b;

  // Helper task for checking results
  task static check_result;
    input [31:0] expected_a_o, expected_b_o;
    begin
      if ((a_o !== expected_a_o) || (b_o !== expected_b_o)) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  aa_i = 0x%h, ab_i = 0x%h", aa_i, ab_i);
        $display("  Expected a: 0x%h | b: 0x%h", expected_a_o, expected_b_o);
        $display("  Got      a: 0x%h | b: 0x%h", a_o, b_o);
        test_failed = 1;
      end
      test_case = test_case + 1;
    end
  endtask

  task static write_to_reg;
    input [31:0] register, val_to_write;
    begin
      //Write to register
      @(negedge clk_i);
      wren_i = 1; wrdata_i = val_to_write; aw_i = register[4:0];
      clk_i = 1;
      //Reset signals
      @(negedge clk_i);
      clk_i = 0;
      wren_i = 0; wrdata_i = 0; aw_i = 0;
      @(negedge clk_i);
    end
  endtask

  initial begin
    // Initialize test variables
    test_failed = 0;
    test_case   = 1;

    // Generate waveform file
    $dumpfile("dump/tb_register_file.vcd");
    $dumpvars(0, tb_register_file);

    ///////////////////////////
    // Comprehensive tests   //
    ///////////////////////////
    for (register = 0; register < 15; register = register + 1) begin
      for (val_to_write = 0; val_to_write < 32'h0000FFFF; val_to_write = val_to_write + 1) begin
        //Write value to register a
        write_to_reg(register, val_to_write);
        //Write value to register b
        write_to_reg(register+1, 32'hFFFF0000 - val_to_write);
        //Read written value
        aa_i = register[4:0]; ab_i = register[4:0]+1;
        if (aa_i == 0) begin
          expected_a = 0;
        end else begin
          expected_a = val_to_write;
        end
        if (ab_i == 0) begin
          expected_b = 0;
        end else begin
          expected_b = 32'hFFFF0000 - val_to_write;
        end

        check_result(expected_a, expected_b);
      end
    end

    // Display test completion message
    if (test_failed) begin
      $display("Some tests failed. Please check the waveform file 'tb_alu.vcd' for debugging.");
    end else begin
      $display("All %0d tests completed successfully!", test_case - 1);
    end

    // Finish simulation
    $finish;
  end
endmodule
