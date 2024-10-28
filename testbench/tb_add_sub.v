`timescale 1ns/1ps

module tb_add_sub ();
    // Inputs
    reg [31:0]  a_i, b_i;
    reg         sub_i;

    // Outputs
    wire [31:0] r_o;
    wire        carry_o;
    wire        zero_o;

    // Instantiate the Unit Under Test (UUT)
    add_sub uut (
        .a_i        (a_i),
        .b_i        (b_i),
        .sub_i      (sub_i),
        .r_o        (r_o),
        .carry_o    (carry_o),
        .zero_o     (zero_o)
    );

    initial begin
        // Generate waveform file
        $dumpfile("dump/tb_add_sub.vcd");
        $dumpvars(0, tb_add_sub);

        // Test ADD two normal numbers operation
        a_i = 42; b_i = 7; sub_i = 0;
        #20;  // wait for circuit to settle

        // Test ADD with carry out operation
        a_i = 'hFFFFFFFF; b_i = 1; sub_i = 0;
        #20;  // wait for circuit to settle

        // Test ADD with sub operation
        a_i = 42; b_i = 7; sub_i = 1;
        #20;  // wait for circuit to settle

        // Test undefined operation (should default to all zeros)
        a_i = 0; b_i = 0; sub_i = 0;
        #20;  // wait for circuit to settle

        // Finish simulation
        $finish();
    end
endmodule