module buttons (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        en_i,
    input  wire [31:0] addr_i,
    input  wire [ 9:0] push_i,
    input  wire [ 7:0] switch_i,
    output wire [31:0] rdata_o
);

// Internal register to hold button and switch states
reg [31:0] val_r;
reg saved_read;

    always @(*) begin
        val_r[9:0]   = push_i;      // push buttons are in bits [9:0]
        val_r[23:16] = switch_i;    // switches are in bits [23:16]
    end

    always @(posedge clk_i) begin
        rdata_o <= 32'h00000000;
        if (!rst_ni) begin
            val_r <= 32'h00000000;
            saved_read <= 1'b0;
        end else begin
            if (saved_read) begin
                rdata_o <= val_r;
            end
            if (en_i && addr_i == 32'h70000000) begin
                saved_read <= 1'b1;
            end;
        end
    end

endmodule
