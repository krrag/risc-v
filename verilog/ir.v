module ir (
    input  wire        clk_i,
    input  wire        enable_i,
    input  wire [31:0] d_i,
    output reg  [31:0] q_o
);

    always @(posedge clk_i) begin
        if (enable_i)
            q_o <= d_i;
    end;

endmodule
