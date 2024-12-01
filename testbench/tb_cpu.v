`timescale 1ns/1ps

module tb_cpu;
  reg        clk_i;
  reg        rst_ni;
  reg [31:0] rdata_i;
  reg [31:0] addr_o;
  reg [31:0] wdata_o;
  reg        we_o;

  // Instantiate design and connect design ports with TB signals
  cpu uut ( .clk_i      (clk_i),
            .rst_ni     (rst_ni),
            .rdata_i    (rdata_i),
            .addr_o     (addr_o),
            .wdata_o    (wdata_o),
            .we_o       (we_o));

  //Testbench variables
  integer i; //Test number
  reg enable_clk; //Activate clock
  integer a, b, c, upp, low; //Test values
  integer previous_pc, next_pc_offset; //Branch test helper variable
  reg signed [31:0] sa;
  reg signed [31:0] sb;

  clock #(.FREQ(800000)) u1(.enable_i(enable_clk), .clk_o(clk_i));

  typedef enum bit [6:0] {
    AND_SRL     = 7'b0110011,
    ADDI        = 7'b0010011,
    LUI         = 7'b0110111,
    LW          = 7'b0000011,
    SW          = 7'b0100011,
    EBREAK      = 7'b1110011,
    B_OPCODE    = 7'b1100011,
    J_OPCODE    = 7'b1101111,
    JALR_OPCODE = 7'b1100111
  } instructions_e;

  typedef enum bit [2:0] {
    BEQ=3'b000,
    BNE=3'b001,
    BLT=3'b100,
    BGE=3'b101,
    BLTU=3'b110,
    BGEU=3'b111
  } branch_op_e;

  branch_op_e b_op;

  // Helper task for checking results
  reg test_failed;
  integer test_case;

  function automatic [31:0] random;
    begin
      random = $urandom;
    end
  endfunction

  task static wait_next_ir;
    begin
      @(negedge clk_i);
      wait(uut.ir_en_w == 1);
      @(negedge clk_i);
    end
  endtask

  task static check_register;
    input [ 4:0] register;
    input [31:0] expected_value;
    reg [31:0] register_value;
    begin
      register_value = uut.rf_inst.reg_array_r[register];
      if (register_value !== expected_value) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("Register 0x%d does not have the good value", register);
        $display("  Expected value: 0x%h", expected_value);
        $display("  Got      value: 0x%h", register_value);
        test_failed = 1;
      end
      test_case = test_case + 1;
    end
  endtask

  task static check_branch_result;
    input [31:0] a;
    input [31:0] b;
    input [ 2:0] b_op;
    input [31:0] b_previous_pc;
    input [31:0] b_next_pc_offset;
    reg [31:0] actual_pc;
    reg [31:0] expected_pc;
    begin
      actual_pc = addr_o;
      sa = a;
      sb = b;
      case (b_op)
        BEQ:  expected_pc = (a  == b)  ? b_previous_pc+b_next_pc_offset : b_previous_pc+4;
        BNE:  expected_pc = (a  != b)  ? b_previous_pc+b_next_pc_offset : b_previous_pc+4;
        BLT:  expected_pc = (sa <  sb) ? b_previous_pc+b_next_pc_offset : b_previous_pc+4;
        BGE:  expected_pc = (sa >= sb) ? b_previous_pc+b_next_pc_offset : b_previous_pc+4;
        BLTU: expected_pc = (a  <  b)  ? b_previous_pc+b_next_pc_offset : b_previous_pc+4;
        BGEU: expected_pc = (a  >= b)  ? b_previous_pc+b_next_pc_offset : b_previous_pc+4;
        default: expected_pc = b_previous_pc+4;
      endcase
      if (actual_pc !== expected_pc) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  Branch 0x%0h result error", b_op);
        $display("  a: 0x%h | b: 0x%h", a, b);
        $display("  Expected pc: 0x%h", expected_pc);
        $display("  Got      pc: 0x%h", actual_pc);
        test_failed = 1;
      end
      test_case = test_case + 1;
    end
  endtask

  task static check_pc;
    input [31:0] expected_pc;
    reg [31:0] actual_pc;
    begin
      actual_pc = addr_o;
      if (actual_pc !== expected_pc) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  PC result error");
        $display("  Expected pc: 0x%h", expected_pc);
        $display("  Got      pc: 0x%h", actual_pc);
        test_failed = 1;
      end
      test_case = test_case + 1;
    end
  endtask

  task static check_o_addr;
    input [31:0] expected_addr;
    reg [31:0] actual_addr;
    begin
      actual_addr = addr_o;
      if (expected_addr !== actual_addr) begin
        $display("Error in test case %0d at time %0t:", test_case, $time);
        $display("  Memory address result error");
        $display("  Expected addr: 0x%h", expected_addr);
        $display("  Got      addr: 0x%h", actual_addr);
        test_failed = 1;
      end
      test_case = test_case + 1;
    end
  endtask


  // This initial block forms the stimulus to test the design
  initial begin
    // Generate waveform file
    $dumpfile("dump/tb_cpu.vcd");
    $dumpvars(0, tb_cpu);

    // 1. Initialize testbench variables
    rst_ni = 0;
    enable_clk = 0;
    rdata_i = 0;

    // 2. Enable clock and reset
    #5
    enable_clk = 1;
    @(negedge clk_i)
    rst_ni = 1;

    // 3. Test all possible instructions
    // TEST1: Load two values in register (LUI + ADDI)
    for(i = 0; i < 5000; i=i+1) begin
      //Reset
      @(negedge clk_i)
      rst_ni = 0;
      @(negedge clk_i)
      rst_ni = 1;

      a = random();
      b = random();
      low = 32'(signed'(a[11:0]));
      upp = a-low;
      @(negedge clk_i)
      rdata_i = {upp[31:12], 5'h01, LUI}; //LUI a in reg1

      wait_next_ir;
      rdata_i = {low[11:0], 5'h01, 3'b000, 5'h01, ADDI}; //ADDI a in reg1

      low = 32'(signed'(b[11:0]));
      upp = b-low;
      wait_next_ir;
      rdata_i = {upp[31:12], 5'h02, LUI}; //LUI b in reg2

      wait_next_ir;
      rdata_i = {low[11:0], 5'h02, 3'b000, 5'h02, ADDI}; //ADDI b in reg2

      wait_next_ir;
      check_register(5'h01, a);
      check_register(5'h02, b);

      //Test2: random() branch operation
      b_op = branch_op_e'(random()[2:0]);
      previous_pc = addr_o;
      next_pc_offset = 32'(signed'({random()[12:2], 2'b00}));
      rdata_i = {next_pc_offset[12], next_pc_offset[10:5], 5'h02, 5'h01,
        b_op, next_pc_offset[4:1], next_pc_offset[11], B_OPCODE};
      wait_next_ir;
      check_branch_result(a, b, b_op, previous_pc, next_pc_offset);

      //Test 3: JAL test
      next_pc_offset = 32'(signed'({random()[20:2], 2'b00}));
      //JAL to offset and old pc should be stored in reg3.
      previous_pc = addr_o;
      rdata_i = {next_pc_offset[20], next_pc_offset[10:1], next_pc_offset[11],
        next_pc_offset[19:12], 5'h03, J_OPCODE};
      wait_next_ir;
      check_register(5'h03,previous_pc+4);
      check_pc(previous_pc+next_pc_offset);

      //Test 4: JALR test
      next_pc_offset = 32'(signed'({random()[11:2], 2'b00}));
      previous_pc = addr_o;
      rdata_i = {next_pc_offset[11:0], 5'h01, 3'h0, 5'h03, JALR_OPCODE};
      wait_next_ir;
      check_register(5'h03,previous_pc+4);
      check_pc(next_pc_offset+{uut.rf_inst.reg_array_r[1][31:2], {2'b00}});

      //Test 5: LOAD - Store random() word from address R4 in R5
      //Store random() address in R4
      sa = 32'(signed'({{1'b0}, random()[30:2], {2'b00}}));
      sb = 32'(signed'({random()[11:2], {2'b00}}));
      low = 32'(signed'(sa[11:0]));
      upp = sa-low;
      rdata_i = {upp[31:12], 5'h04, LUI}; //LUI a in reg4
      wait_next_ir;
      rdata_i = {low[11:0], 5'h04, 3'h0, 5'h04, ADDI}; //ADDI a in reg4
      wait_next_ir;
      //LOAD1
      rdata_i = {sb[11:0], 5'h04, 3'h0, 5'h05, LW};
      @(negedge clk_i) //Wait 2 ticks until controller is in LOAD1 state and outputs address
      @(negedge clk_i)
      check_o_addr(sa+sb);
      @(negedge clk_i) //Wait 1 ticks until controller is in LOAD2 state and ready to load val in R5
      //LOAD2
      c = random();
      rdata_i = {c};
      wait_next_ir;
      check_register(5'h05, c);

    end
    $finish;
  end
endmodule
