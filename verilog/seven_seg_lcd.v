module seven_seg_lcd (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        en_i,
    input  wire        we_i,
    input  wire [31:0] waddr_i,
    input  wire [31:0] wdata_i,
    output reg [31:0] disp_o
);

    always @(posedge clk_i) begin
        if (!rst_ni)
            disp_o <= 32'h00000000;
        else if (en_i &&  we_i && (waddr_i == 32'h60000000))
            disp_o <= wdata_i;
    end

endmodule
