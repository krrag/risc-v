`timescale 1ns/1ps
`define ASSERT(ARG) if (!(ARG)) begin $error("Error"); $finish; end

module tb_mux4x32 ();
    // Inputs
    reg [31:0] a_i, b_i, c_i, d_i;
    reg [ 1:0] sel_i;

    // Outputs
    wire [31:0] o_o;

    // Instantiate the Unit Under Test (UUT)
    mux4x32 uut (
        .a_i        (a_i),
        .b_i        (b_i),
        .c_i        (c_i),
        .d_i        (d_i),
        .sel_i      (sel_i),
        .o_o        (o_o)
    );

    localparam A = 2'b00;
    localparam B = 2'b01;
    localparam C = 2'b10;
    localparam D = 2'b11;

    initial begin
        // Generate waveform file
        $dumpfile("dump/tb_mux4x32.vcd");
        $dumpvars(0, tb_mux4x32);

        //Use all same values for all tests
        a_i = 32'hF; b_i = 32'hF0; c_i = 32'hF00; d_i = 32'hF000;

        // Test to select entry A
        sel_i = A;
        #10;  // wait for circuit to settle
        `ASSERT(o_o == a_i);
        #10;

        // Test to select entry B
        sel_i = B;
        #10;  // wait for circuit to settle
        `ASSERT(o_o == b_i);
        #10;

        // Test to select entry C
        sel_i = C;
        #10;  // wait for circuit to settle
        `ASSERT(o_o == c_i);
        #10;

        // Test to select entry D
        sel_i = D;
        #10;  // wait for circuit to settle
        `ASSERT(o_o == d_i);
        #10;

        // Finish simulation
        $finish();
    end
endmodule