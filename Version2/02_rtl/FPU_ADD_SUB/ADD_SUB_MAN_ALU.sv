module ADD_SUB_MAN_ALU #(
    parameter NUM_OP    = 1 ,
    parameter SIZE_MAN  = 24
)(
    input logic [NUM_OP-1:0]    i_fpu_op        ,
    input logic                 i_sign_a        ,
    input logic                 i_sign_b        ,
    input logic                 i_carry         ,
    input logic                 i_E_zero_A      ,
    input logic                 i_E_zero_B      ,
    input logic [SIZE_MAN-1:0]  i_man_max       ,
    input logic [SIZE_MAN-1:0]  i_man_min       ,
    output logic [SIZE_MAN-1:0] o_man_alu       ,
    output logic                o_overflow       
);

logic w_i_fpu_op;
logic w_i_carry_alu;
logic [SIZE_MAN-1:0] w_n_man_b;
logic [SIZE_MAN-1:0] w_i_man_b;
logic [SIZE_MAN-1:0] w_o_man_alu;
logic w_overflow;

logic w_M_zero_A, w_M_zero_B;
assign w_M_zero_A = ~|(i_man_max[SIZE_MAN-2:0]) & i_E_zero_A;
assign w_M_zero_B = ~|(i_man_min[SIZE_MAN-2:0]) & i_E_zero_B;

// assign w_i_fpu_op = i_fpu_op ? ~(i_sign_a ^ i_sign_b) : (i_sign_a ^ i_sign_b);
assign w_i_fpu_op = i_fpu_op ? (i_sign_a ^ i_sign_b) : ~(i_sign_a ^ i_sign_b);
assign w_n_man_b = ~(i_man_min);
// assign w_i_man_b = w_i_fpu_op ? w_n_man_b : i_man_min;
assign w_i_man_b = w_i_fpu_op ? i_man_min : w_n_man_b;
// assign w_i_carry_alu = (~i_carry) & w_i_fpu_op;
assign w_i_carry_alu = ~(i_carry | w_i_fpu_op);

ADD_SUB_CLA_24bit ALU_SUB_UNIT (
    .i_carry        (w_i_carry_alu),
    .i_data_a       (i_man_max),
    .i_data_b       (w_i_man_b),
    .o_sum          (w_o_man_alu),
    .o_carry        (w_overflow)
);
// assign {w_overflow, o_man_alu} = {1'b0, i_man_max} + {1'b0, w_i_man_b} + w_i_carry_alu;
assign o_man_alu = w_M_zero_A ? i_man_min : (w_M_zero_B ? i_man_max : w_o_man_alu);
// assign o_overflow = w_i_fpu_op ? 1'b0 : w_overflow;
assign o_overflow = w_M_zero_A | w_M_zero_B ? '0 : (w_i_fpu_op ? w_overflow : 1'b0);

endmodule
