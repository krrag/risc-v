module register_file (
    input  wire        clk_i,
    input  wire [ 4:0] aa_i,
    input  wire [ 4:0] ab_i,
    input  wire [ 4:0] aw_i,
    input  wire        wren_i,
    input  wire [31:0] wrdata_i,
    output wire [31:0] a_o,
    output wire [31:0] b_o
);
  /////////////////////
  // Internal Registers
  /////////////////////
  //! Do not rename the reg_array_r signal
  //! Use it to store the register file contents
  reg [31:0] reg_array_r[32];

endmodule
