`timescale 1ns/1ps

module tb_controller ();

// Inputs
reg clk_i;
reg rst_ni;

reg [31:0] instruction_i;

//Outputs
reg branch_op_o;
reg [31:0] imm_o;
reg ir_en_o;
reg pc_add_imm_o;
reg pc_en_o;
reg pc_sel_alu_o;
reg pc_sel_pc_base_o;
reg rf_we_o;
reg sel_addr_o;
reg sel_b_o;
reg sel_mem_o;
reg sel_pc_o;
reg sel_imm_o;
reg we_o;
reg [5:0] alu_op_o;


controller uut
(
    .rst_ni (rst_ni),
    .clk_i (clk_i),
    .instruction_i (instruction_i),
    .branch_op_o (branch_op_o),
    .imm_o (imm_o),
    .ir_en_o (ir_en_o),
    .pc_add_imm_o (pc_add_imm_o),
    .pc_en_o (pc_en_o),
    .pc_sel_alu_o (pc_sel_alu_o),
    .pc_sel_pc_base_o (pc_sel_pc_base_o),
    .rf_we_o (rf_we_o),
    .sel_addr_o (sel_addr_o),
    .sel_b_o (sel_b_o),
    .sel_mem_o (sel_mem_o),
    .sel_pc_o (sel_pc_o),
    .sel_imm_o (sel_imm_o),
    .we_o (we_o),
    .alu_op_o (alu_op_o)
);

reg test_failed;
integer test_case;
reg [5:0] alu_comp;

task static check_result;
    input expected_b_op;
    input [31:0] expected_imm;
    input expected_ir;
    input expected_pc_add;
    input expected_pc_en;

    input expected_pc_sel_alu;
    input expected_pc_sel_base;
    input expected_rf;
    input expected_sel_addr;
    input expected_sel_b;

    input expected_sel_mem;
    input expected_sel_pc;
    input expected_sel_imm;
    input expected_we;
    input [5:0] expected_alu;

    input only_add_op; // If load => check 2 first bit since it's addition
    begin
        #10
        alu_comp = only_add_op === 1 ? {alu_op_o[5:3], 3'b0} : alu_op_o;
        if (expected_b_op !== branch_op_o |
            expected_imm !== imm_o |
            expected_ir !== ir_en_o |
            expected_pc_add !== pc_add_imm_o |
            expected_pc_en !== pc_en_o |
            expected_pc_sel_alu !== pc_sel_alu_o |
            expected_pc_sel_base !== pc_sel_pc_base_o |
            expected_rf !== rf_we_o |
            expected_sel_addr !== sel_addr_o |
            expected_sel_b !== sel_b_o |
            expected_sel_mem !== sel_mem_o |
            expected_sel_pc !== sel_pc_o |
            expected_sel_imm !== sel_imm_o |
            expected_we !== we_o |
            expected_alu !== alu_comp
        ) begin
            $display("Error in test case %0d at time %0t:", test_case, $time);
            $display("  instruction_i: 0x%h", instruction_i);
            $display("  Expected:");
            $display("      imm = 0x%h, branch_op = %0d, ir_en = %0d",
            expected_imm, expected_b_op, expected_ir);
            $display("      pc_add_imm = %0d, pc_en = %0d, pc_sel_alu = %0d, pc_sel_pc_base = %0d",
            expected_pc_add, expected_pc_en, expected_pc_sel_alu, expected_pc_sel_base);
            $display("      rf_we = %0d, sel_addr = %0d, sel_b = %0d, sel_mem = %0d",
            expected_rf, expected_sel_addr, expected_sel_b, expected_sel_mem);
            $display("      sel_pc = %0d, sel_imm = %0d, we = %0d, alu_op = %06b",
            expected_sel_pc, expected_sel_imm, expected_we, expected_alu);
            $display("  Got:");
            $display("      imm = 0x%h, branch_op = %0d, ir_en = %0d",
            imm_o, branch_op_o, ir_en_o);
            $display("      pc_add_imm = %0d, pc_en = %0d, pc_sel_alu = %0d, pc_sel_pc_base = %0d",
            pc_add_imm_o, pc_en_o, pc_sel_alu_o, pc_sel_pc_base_o);
            $display("      rf_we = %0d, sel_addr = %0d, sel_b = %0d, sel_mem = %0d",
            rf_we_o, sel_addr_o, sel_b_o, sel_mem_o);
            $display("      sel_pc = %0d, sel_imm = %0d, we = %0d, alu_op = %06b",
            sel_pc_o, sel_imm_o, we_o, alu_comp);
            test_failed = 1;
            $display("");
        end
        test_case = test_case + 1;
    end

endtask;

localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk_i=~clk_i;

initial begin
    $dumpfile("dump/tb_controller.vcd");
    $dumpvars(0, tb_controler);
end

reg [5:0] funct3 [8]= {
    6'b000000, 6'b110001, 6'b011100, 6'b011110,
    6'b100100, 6'b110101, 6'b100110, 6'b100111
};
reg [2:0] funct3_b [6] = {
    3'b000, 3'b001, 3'b100,
    3'b101, 3'b110, 3'b111
};
reg [5:0] alu_op_b [6] = {
    6'b011000, 6'b011001, 6'b011100,
    6'b011101, 6'b011110, 6'b011111
};
reg [6:0] funct7 = 7'b0100000;

localparam R_TYPE = 32'b00000000000000000000000000110011;
localparam I_TYPE = 32'b00000000000000000000000000010011;
localparam U_TYPE = 32'b00000000000000000000000000110111;
localparam B_TYPE = 32'b00000000000000000000000001100011;
localparam LOAD_TYPE = 32'b00000000000000000000000000000011;
localparam S_TYPE = 32'b00000000000000000000000000100011;
localparam J_TYPE = 32'b00000000000000000000000001101111;
localparam BREAK_TYPE = 32'b00000000000000000000000001110011; // not really interesting tbh
localparam JALR_TYPE = 32'b00000000000000000000000001100111;

initial begin
    ///////// WARNING : THE CHECK_RESULT TASK IS EQUIVALENT TO #10; ////////
    #5;
    instruction_i = 0;
    rst_ni = 0;
    #10;
    rst_ni = 1;
    check_result(
        0, 0, 1, 0, 1,
        0, 0, 0, 0, 0,
        0, 0, 0, 0 ,0,
        0
    );
    // from 0 to 8 => all funct3
    for (int i = 0; i < 8 ; i = i + 1) begin
        // R TYPE => 51
        instruction_i = R_TYPE;
        instruction_i = instruction_i | i << 12;
        // Fetch 1
        rst_ni = 0;
        check_result(
            0, 0, 0, 0, 0,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, funct3[i],
            0
        );
        // Fetch 2
        rst_ni = 1;
        check_result(
            0, 0, 1, 0, 1,
            0, 0, 0, 0, 0,
            0, 0, 0, 0, funct3[i],
            0
        );
        // Decode
        #10;
        // Execute state ()
        check_result(
        0, 0, 0, 0, 0,
        0, 0, 1, 0, 1,
        0, 0, 0, 0, funct3[i],
        0
        );
    end
    // Funct 7 variant
    begin
        //SUB
        // Entering here as FETCH2 state because R_TYPE
        instruction_i = R_TYPE;
        instruction_i = instruction_i | funct7 << 25;
        #10;
        //Decode
        #10;
        //Execute
        check_result(
        0, 0, 0, 0, 0,
        0, 0, 1, 0, 1,
        0, 0, 0, 0, 6'b001000,
        0
        );
        //SRA
        instruction_i = instruction_i | 5 << 12;
        #20;
        check_result(
        0, 0, 0, 0, 0,
        0, 0, 1, 0, 1,
        0, 0, 0, 0, 6'b111101,
        0
        );
    end
    // Result is the same for I_TYPE the sole difference is for sub instruction and sel_b = 0
    for (int i = 0; i < 8 ; i = i + 1) begin
        // R TYPE => 51
        instruction_i = I_TYPE;
        instruction_i = instruction_i | i << 12;
        // Fetch 1
        rst_ni = 0;
        #10;
        // Fetch 2
        rst_ni = 1;
        #10;
        // Decode
        #10;
        // Execute state ()
        check_result(
        0, 0, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 0, funct3[i],
        0
        );
        // After check_result we are at fetch 1 instantly
    end

    // Funct 7 variant
    begin
        //SUBI, this should ignore funct7 value for alu_op but imm = 0x00000400 which is 0b010000000000 === 1024
        instruction_i = I_TYPE;
        instruction_i = instruction_i | funct7 << 25;
        #20;
        check_result(
        0, 32'h400, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 0, 6'b000000,
        0
        );
        //SRAI
        instruction_i = instruction_i | 5 << 12;
        #20;
        check_result(
        0, 32'h400, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 0, 6'b111101,
        0
        );
    end

    // U_TYPE

    begin
        instruction_i = U_TYPE;
        instruction_i = instruction_i | 1 << 12;
        #20;
        check_result(
            0, 1 << 12, 0, 0, 0,
            0, 0, 1, 0, 0,
            0, 0, 1, 0, 6'b000000,
            0
        );
    end

    //B_TYPE
    for (int i = 0; i < 6; i = i + 1) begin
        instruction_i = B_TYPE;
        instruction_i = instruction_i | {29'd0,funct3_b[i]} << 12 | i << 25;
        // Fetch 1
        rst_ni = 0;
        #10;
        // Fetch 2
        rst_ni = 1;
        #10;
        // Decode
        #10;
        // Execute state ()
        check_result(
            1, i << 5, 0, 1, 0,
            0, 1, 0, 0, 1,
            0, 0, 0, 0, alu_op_b[i],
            0
        );
    end

    //LOAD_TYPE
    // Will be taking advantage that LOAD2 => FETCH1 so we reset prior to the loop
    // I am not checking immediate value since it's trivial enough to implement
    rst_ni = 0;
    instruction_i = LOAD_TYPE;
    #10;
    // fetch2
    rst_ni = 1;
    #40;

    for (int i = 0; i < 8; i = i + 1) begin
        // Fetch 1
        instruction_i = LOAD_TYPE;
        instruction_i = instruction_i | i << 12;
        #10;
        // Fetch 2
        #10;
        // Decode
        #10;
        // LOAD1
        check_result(
            0, 0, 0, 0, 0,
            0, 0, 0, 1, 0,
            0, 0, 0, 0, 0,
            1
        );
        // LOAD2
        check_result(
            0, 0, 0, 0, 0,
            0, 0, 1, 1, 0,
            1, 0, 0, 0, 0,
            1
        );
        // Back to Fetch 1
    end

    // S_TYPE
    rst_ni = 0;
    instruction_i = S_TYPE;
    #10;
    // fetch2
    rst_ni = 1;
    #30;

    for (int i = 0; i < 8; i = i + 1) begin
        instruction_i = S_TYPE;
        instruction_i = instruction_i | i << 12;
        #30;
        // Store
        check_result(
            0, 0, 0, 0, 0,
            0, 0, 0, 1, 0,
            0, 0, 0, 1, 0,
            1
        );
    end

    //J_TYPE
    rst_ni = 0;
    instruction_i = J_TYPE;
    #10;
    // fetch2
    rst_ni = 1;
    #30;

    for (int i = 0; i < 1024; i = i + 1) begin
        instruction_i = J_TYPE;
        instruction_i = instruction_i | i << 21;
        #30;
        // Store
        check_result(
            0, i << 1, 0, 1, 1,
            0, 1, 1, 0, 0,
            0, 1, 0, 0, 0,
            1
        );
    end

    // JALR TYPE
    rst_ni = 0;
    instruction_i = JALR_TYPE;
    #10;
    // fetch2
    rst_ni = 1;
    #30;

    for (int i = 0; i < 8; i = i + 1) begin
        instruction_i = JALR_TYPE;
        instruction_i = instruction_i | i << 12;
        #30;
        // Store
        check_result(
            0, 0, 0, 0, 1,
            1, 0, 1, 0, 0,
            0, 1, 0, 0, 0,
            1
        );
    end



    if (test_failed) $display("Some tests failed. Please check"+
                        "the waveform file 'tb_controller.vcd' for debugging.");
        else $display("All %0d tests completed successfully!", test_case - 1);
        $finish;
end

endmodule
