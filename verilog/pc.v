module pc (
    input  wire        clk_i,
    input  wire        rst_ni,
    input  wire        en_i,
    input  wire        sel_alu_i,
    input  wire        sel_pc_base_i,
    input  wire        add_imm_i,
    input  wire [31:0] imm_i,
    input  wire [31:0] alu_i,
    output reg [31:0] addr_o
);

    always @(posedge clk_i) begin
        if (!rst_ni)
            addr_o <= 32'h80000000;
        else if (en_i) begin
            if (add_imm_i)
                //JUMP or branch. if branch, take into account that PC was incremented during FETCH
                addr_o <= (addr_o + imm_i - (sel_pc_base_i ? 4 : 0)) & ~32'h00000003;
            else
                //If JALR, then use ALU result, else increment normally.
                addr_o <= (sel_alu_i ? alu_i : addr_o + 4) & ~32'h00000003;
        end
    end

endmodule
