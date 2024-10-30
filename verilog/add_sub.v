module add_sub (
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire        sub_i,
    output wire        carry_o,
    output wire        zero_o,
    output wire [31:0] r_o
);

    //Working : assign {carry_o, r_o} = sub_i ? a_i-b_i : a_i+b_i;
    // Prefered for explicit 2's complement :
    //edge case for 0 necessitates to set carry during sub for correct comparison
    assign {carry_o, r_o} = {1'b0,a_i} + (sub_i ? ({1'b0,(~b_i)}+1) : {1'b0,b_i}); 
    assign zero_o = (r_o == 32'b0);

endmodule
