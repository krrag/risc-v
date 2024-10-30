`timescale 1ns/1ps
`define ASSERT(ARG) if (!(ARG)) begin $error("Error"); $finish; end

module tb_comparator ();
    // Branch operations
    localparam EQ = 3'b000;
    localparam NE = 3'b001;
    localparam LT = 3'b100;
    localparam GE = 3'b101;
    localparam LTU = 3'b110;
    localparam GEU = 3'b111;

    // Inputs
    reg         a_31_i, b_31_i;
    reg         diff_31_i, carry_i, zero_i;
    reg [2:0]   op_i;

    // Outputs
    wire        r_o;

    // Instantiate the Unit Under Test (UUT)
    comparator uut (
        .a_31_i     (a_31_i),
        .b_31_i     (b_31_i),
        .diff_31_i  (diff_31_i),
        .carry_i    (carry_i),
        .zero_i     (zero_i),
        .op_i       (op_i),
        .r_o        (r_o)
    );

    initial begin
        // Generate waveform file
        $dumpfile("dump/tb_comparator.vcd");
        $dumpvars(0, tb_comparator);

        // Test EQ with a equals b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 1; op_i = EQ;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 1)
        #10;

        // Test EQ with a not equals b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = EQ;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 0);
        #10;

        // Test NE with a equals b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 1; op_i = NE;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 0);
        #10;

        // Test NE with a not equals b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = NE;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 1);
        #10;

        // Test LTU with a < b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = LTU;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 1);
        #10;

        // Test LTU with a > b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 1; zero_i = 0; op_i = LTU;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 0);
        #10;

        // Test LTU with a > b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 1; op_i = LTU;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 0);
        #10;

        // Test GEU with a < b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = GEU;
        #10;  // wait for circuit to settle
        `ASSERT(r_o == 0);
        #10;

        // Test GEU with a >= b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 1; zero_i = 0; op_i = GEU;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test GEU with a >= b
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 1; op_i = GEU;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test LT with a negative and b positive
        a_31_i = 1; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = LT;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test LT with a positive and b negative
        a_31_i = 0; b_31_i = 1; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = LT;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 0);
        #10;

        // Test LT with a and b same sign and difference is negative
        a_31_i = 0; b_31_i = 0; diff_31_i = 1; carry_i = 0; zero_i = 0; op_i = LT;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test LT with a and b same sign and difference is negative
        a_31_i = 1; b_31_i = 1; diff_31_i = 1; carry_i = 0; zero_i = 0; op_i = LT;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test GE with a positive and b negative
        a_31_i = 0; b_31_i = 1; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = GE;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test GE with a negative and b positive
        a_31_i = 1; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = GE;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 0);
        #10;

        // Test LT with a and b having the same sign and difference non negative
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = GE;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 1);
        #10;

        // Test LT with a and b having the same sign and difference negative
        a_31_i = 0; b_31_i = 0; diff_31_i = 1; carry_i = 0; zero_i = 0; op_i = GE;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 0);
        #10;

        // Test undefined operation should give back zero
        a_31_i = 0; b_31_i = 0; diff_31_i = 0; carry_i = 0; zero_i = 0; op_i = 0;
        #10;  // wait for circuit to settle
       `ASSERT(r_o == 0);
        #10;
        
        // Finish simulation
        $finish();
    end
endmodule