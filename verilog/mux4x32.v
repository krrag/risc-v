module mux4x32 (
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [31:0] c_i,
    input  wire [31:0] d_i,
    input  wire [ 1:0] sel_i,
    output wire [31:0] o_o
);

    reg [31:0] o_reg;

    always @(*) begin
        case(sel_i)
            2'b00 :    o_reg = a_i;
            2'b01 :    o_reg = b_i;
            2'b10 :    o_reg = c_i;
            2'b11 :    o_reg = d_i;
            default :  o_reg = 32'b0;
        endcase
    end;

    assign o_o = o_reg;

endmodule
