module decoder (
    input  wire [31:0] addr_i,
    output wire        en_ram_o,
    output wire        en_leds_o,
    output wire        en_7_seg_lcd_o,
    output wire        en_buttons_o
);

    always @(*) begin
        // Default values
        en_ram_o       = 1'b0;
        en_leds_o      = 1'b0;
        en_7_seg_lcd_o = 1'b0;
        en_buttons_o   = 1'b0;

        // Address range decoding
        if (addr_i >= 32'h80000000 && addr_i <= 32'h9FFFFFFF)
            en_ram_o = 1'b1;
        else if (addr_i >= 32'h70000000 && addr_i <= 32'h70000FFF)
            en_buttons_o = 1'b1;
        else if (addr_i >= 32'h60000000 && addr_i <= 32'h60000FFF)
            en_7_seg_lcd_o = 1'b1;
        else if (addr_i >= 32'h50000000 && addr_i <= 32'h50000FFF)
            en_leds_o = 1'b1;
    end

endmodule
