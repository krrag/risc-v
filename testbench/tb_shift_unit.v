`timescale 1ns / 1ps
`undef ASSERT
`define ASSERT(ARG) if (!(ARG)) begin $error("Error: a_i=0x%0h r_o=0x%0h", a_i, r_o); $finish; end

module tb_shift_unit ();
    // Inputs
    reg [31:0] a_i, b_i;
    reg [2:0]  op_i;
    reg arithmetic_i;

    // Outputs
    wire [31:0] r_o;

    // Instantiate the Unit Under Test (UUT)
    shift_unit uut (
        .a_i  (a_i),
        .b_i  (b_i),
        .op_i (op_i),
        .arithmetic_i (arithmetic_i),
        .r_o  (r_o)
    );

    // Operation codes (matching the shift_unit module)
                // opcode + special bit
    localparam SLL  = 4'b0010; //Shift Left Logical
    localparam SRL  = 4'b1010; //Shift Right Logical
    localparam SRA  = 4'b1011; //Shift Right Arithmetic

    initial begin
        // Generate waveform file
        $dumpfile("dump/tb_shift_unit.vcd");
        $dumpvars(0, tb_shift_unit);

        // Test SLL operation
        a_i = 32'hF0; b_i = 4; {op_i,arithmetic_i} = SLL;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 32'h0F00);
        #10;

        // Test SRL operation
        a_i = 32'hF0; b_i = 4; {op_i,arithmetic_i} = SRL;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 32'h0F);
        #10;

        // Test SRA operation
        a_i = 32'hF0000000; b_i = 4; {op_i,arithmetic_i} = SRA;
        #10;  // wait for circuit to settle
        //$display("%0b", {1'b0, op_i} << 1 | {{3{1'b0}}, arithmetic_i});
       `ASSERT(r_o == 32'hFF000000);
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
