module shift_unit (
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [ 2:0] op_i,
    input  wire        arithmetic_i,
    output wire [31:0] r_o
);

    reg [31:0] r_reg;

    always @(*) begin
        case(op_i)
            3'b001 :    r_reg = a_i<<b_i[4:0];
            3'b101 :    r_reg = arithmetic_i ? $signed($signed(a_i) >>> b_i[4:0]) : a_i >> b_i[4:0];
            default :   r_reg = 32'b0;
        endcase
    end;

    assign r_o = r_reg;

endmodule
