`timescale 1ns / 1ps
`define ASSERT(ARG) if (!(ARG)) begin $error("Error"); $finish; end

module tb_logic_unit ();
    // Inputs
    reg [31:0] a_i, b_i;
    reg [2:0]  op_i;

    // Outputs
    wire [31:0] r_o;

    // Instantiate the Unit Under Test (UUT)
    logic_unit uut (
        .a_i  (a_i),
        .b_i  (b_i),
        .op_i (op_i),
        .r_o  (r_o)
    );

    // Operation codes (matching the logic_unit module)
    localparam XOR = 3'b100;
    localparam OR  = 3'b110;
    localparam AND = 3'b111;

    initial begin
        // Generate waveform file
        $dumpfile("dump/tb_logic_unit.vcd");
        $dumpvars(0, tb_logic_unit);

        // Test XOR operation
        a_i = 32'hF0; b_i = 32'hFF; op_i = XOR;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 32'h0F);
        #10;

        // Test OR operation
        a_i = 32'hF0; b_i = 32'hFF; op_i = OR;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 32'hFF);
        #10;

        // Test AND operation
        a_i = 32'hF0; b_i = 32'hFF; op_i = AND;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 32'hF0);
        #10;

        // Test undefined operation (should default to all zeros)
        a_i = 0; b_i = 0; op_i = 0;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 0);
        #10;

        // Finish simulation
        $finish;
    end
endmodule
