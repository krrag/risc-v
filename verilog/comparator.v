module comparator (
    input  wire       a_31_i,
    input  wire       b_31_i,
    input  wire       diff_31_i,
    input  wire       carry_i,
    input  wire       zero_i,
    input  wire [2:0] op_i,
    output wire       r_o
);

    reg r_reg;
    always @(*) begin
        case(op_i)
            //A=B
            3'b000 :    r_reg = zero_i;
            //A!=B
            3'b001 :    r_reg = ~zero_i;
            //A<B (signed)
            3'b100 :    r_reg = (a_31_i & (!b_31_i)) | (((a_31_i ~^ b_31_i)) & diff_31_i);
            //A>=B (signed)
            3'b101 :    r_reg = (!(a_31_i) & b_31_i) | (((a_31_i ~^ b_31_i)) & (!diff_31_i));
            //A<B (unsigned)
            3'b110 :    r_reg = !(carry_i | zero_i);
            //A>=B (unsigned)
            3'b111 :    r_reg = carry_i | zero_i;
            default :   r_reg = 1'b0;
        endcase
    end;

    assign r_o = r_reg;

endmodule
