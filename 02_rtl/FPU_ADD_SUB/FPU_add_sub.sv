module FPU_add_sub #(
    parameter NUM_OP    = 1
)(
    input logic [NUM_OP-1:0]    i_add_sub       ,
    input logic [31:0]          i_32_a          ,
    input logic [31:0]          i_32_b          ,
    output logic [31:0]         o_32_s           
);

////////////////////////////////////////////////////////////////
// Expact
////////////////////////////////////////////////////////////////
logic w_sign_a, w_sign_b;
logic [7:0] w_exponent_a, w_exponent_b;
logic [23:0] w_mantissa_a, w_mantissa_b;
assign w_sign_a = i_32_a[31];
assign w_sign_b = i_32_b[31];
assign w_exponent_a = i_32_a[30:23];
assign w_exponent_b = i_32_b[30:23]; 
assign w_mantissa_a = {1'b1, i_32_a[22:0]};
assign w_mantissa_b = {1'b1, i_32_b[22:0]};

logic w_sign_result;
logic [7:0] w_exponent_result;
logic [22:0] w_mantissa_result;
////////////////////////////////////////////////////////////////
// Internal Signals
////////////////////////////////////////////////////////////////
logic EXP_COMP_o_compare;
logic [7:0] EXP_SWAP_o_max;
logic [7:0] EXP_SWAP_o_min;
logic [7:0] EXP_SUB_o_sub;
logic [23:0] MAN_SWAP_PRE_man_max;
logic [23:0] MAN_SWAP_PRE_man_min;
logic [23:0] MAN_SWAP_PRE_SHF_man_min;
logic [31:0] SHF_RIGHT_MAN_o_data;
logic [7:0] SHF_RIGHT_NOR_rounding;
logic MAN_COM_o_compare;
logic [23:0] MAN_SWAP_max;
logic [23:0] MAN_SWAP_min;

logic [3:0]  CLS_MAN_ALU_i_data;
logic [3:0]  CLS_MAN_ALU_o_data;
logic        CLS_MAN_ALU_bout;
logic [23:0] MAN_ALU_man_alu;
logic MAN_ALU_ov_flag;
logic [1:0] PSC_sel_man;
logic       PSC_sel_exp;

logic [4:0] LOPD_o_one_position;
logic       LOPD_o_zero_flag;

logic [7:0] EXP_ADJUST_exp_result;
logic [31:0] NOR_o_man;
logic MAN_RND_ov_flag;

logic [7:0]  EXP_RND_exp;
logic [23:0] MAN_RND_man;

////////////////////////////////////////////////////////////////
// Submodules
////////////////////////////////////////////////////////////////

// Exponent preprocessing
EXP_comp #(
    .SIZE_DATA          (8)
) EXP_COM_8BIT (
    .i_data_a          (w_exponent_a),
    .i_data_b          (w_exponent_b),
    .o_compare         (EXP_COMP_o_compare) // a < b
);
EXP_swap #(
    .SIZE_DATA          (8)
) EXP_SWAP (
    .i_data_a           (w_exponent_a),
    .i_data_b           (w_exponent_b),
    .i_compare          (EXP_COMP_o_compare),   // a < b
    .o_less_data        (EXP_SWAP_o_min),
    .o_greater_data     (EXP_SWAP_o_max) 
);
EXP_sub #(
    .SIZE_EXP_SUB       (8)
) EXP_SUB (
    .i_data_a           (EXP_SWAP_o_max),
    .i_data_b           (EXP_SWAP_o_min),
    .o_sub              (EXP_SUB_o_sub)        
);
MAN_swap #(
    .SIZE_MAN           (24)
) MAN_SWAP_PRE (
    .i_man_a            (w_mantissa_a),
    .i_man_b            (w_mantissa_b),
    .i_compare          (EXP_COMP_o_compare),
    .o_man_max          (MAN_SWAP_PRE_man_max),
    .o_man_min          (MAN_SWAP_PRE_man_min) 
);
SHF_right #(
    .SIZE_DATA          (32),
    .SIZE_SHIFT         (5 ) 
) SHF_RIGHT_MAN (
    .i_shift_number     (EXP_SUB_o_sub[4:0]),
    .i_data             ({MAN_SWAP_PRE_man_min, 8'b0}), 
    .o_data             (SHF_RIGHT_MAN_o_data)
);
assign MAN_SWAP_PRE_SHF_man_min = SHF_RIGHT_MAN_o_data[31:8];
assign SHF_RIGHT_NOR_rounding   = {SHF_RIGHT_MAN_o_data[7:0]};

COMP_24bit #(
    .SIZE_DATA          (24)
) MAN_COMP_24BIT (
    .i_data_a           (MAN_SWAP_PRE_man_max),
    .i_data_b           (MAN_SWAP_PRE_SHF_man_min),
    .o_less             (MAN_COM_o_compare)
);
SIGN_unit SIGN_UNIT (
    .i_add_sub          (i_add_sub),
    .i_comp_man         (MAN_COM_o_compare | EXP_COMP_o_compare),
    .i_sign_man_a       (w_sign_a),
    .i_sign_man_b       (w_sign_b),
    .o_sign_s           (w_sign_result) 
);
PSC_unit PSC_UNIT(
    .i_add_sub          (i_add_sub),
    .i_sign_a           (w_sign_a),
    .i_exp_a            (w_exponent_a),
    .i_man_a            (w_mantissa_a),
    .i_sign_b           (w_sign_b),
    .i_exp_b            (w_exponent_b),
    .i_man_b            (w_mantissa_b),
    .o_sel_exp          (PSC_sel_exp),
    .o_sel_man          (PSC_sel_man) 
);
MAN_swap #(
    .SIZE_MAN           (24)
) MAN_SWAP (
    .i_man_a            (MAN_SWAP_PRE_man_max),
    .i_man_b            (MAN_SWAP_PRE_SHF_man_min),
    .i_compare          (MAN_COM_o_compare),
    .o_man_max          (MAN_SWAP_max),
    .o_man_min          (MAN_SWAP_min) 
);

assign CLS_MAN_ALU_i_data = {SHF_RIGHT_NOR_rounding[7], SHF_RIGHT_NOR_rounding[6], SHF_RIGHT_NOR_rounding[5], SHF_RIGHT_NOR_rounding[4]};
CLS_4bit MAN_ALU_PROC_RND (
    .A                  (4'b0),
    .B                  (CLS_MAN_ALU_i_data),
    .Bin                (1'b0),
    .SUB                (CLS_MAN_ALU_o_data),
    .Bout               (CLS_MAN_ALU_bout) 
);

MAN_ALU #(
    .NUM_OP             (NUM_OP),
    .SIZE_MAN           (24)
) MAN_ALU (
    .i_fpu_op           (i_add_sub),
    .i_sign_a           (w_sign_a),
    .i_sign_b           (w_sign_b),
    .i_carry            (CLS_MAN_ALU_bout),
    .i_man_max          (MAN_SWAP_max),
    .i_man_min          (MAN_SWAP_min),
    .o_man_alu          (MAN_ALU_man_alu),
    .o_overflow         (MAN_ALU_ov_flag) 
);
LOPD_24bit #(
    .SIZE_DATA          (24),
    .SIZE_LOPD          (5)      
) LOPD_24BIT (
    .i_data             (MAN_ALU_man_alu),
    .o_one_position     (LOPD_o_one_position),
    .o_zero_flag        (LOPD_o_zero_flag) 
);
EXP_adjust #(
    .SIZE_EXP           (8),
    .SIZE_LOPD          (8)      
) EXP_ADJUST (
    .i_overflow         (MAN_ALU_ov_flag),
    .i_underflow        (MAN_ALU_man_alu[23]),
    .i_zero_flag        (LOPD_o_zero_flag),
    .i_lopd_value       ({3'b0, LOPD_o_one_position}),
    .i_exp_value        (EXP_SWAP_o_max),
    .o_exp_result       (EXP_ADJUST_exp_result)
);

NOR_unit #(
    .SIZE_LOPD          (5) ,
    .SIZE_DATA          (32)
) NOR_UNIT (
    .i_overflow         (MAN_ALU_ov_flag),
    .i_zero_flag        (LOPD_o_zero_flag),
    .i_one_position     (LOPD_o_one_position),
    .i_mantissa         ({MAN_ALU_man_alu, CLS_MAN_ALU_o_data, 4'b0}),
    .o_mantissa         (NOR_o_man) 
);

MAN_rounding #(
    .SIZE_MAN           (32),
    .SIZE_MAN_RESULT    (24)
) MAN_RND (
    .i_man              (NOR_o_man),
    .o_man_result       (MAN_RND_man),
    .o_ov_flow          (MAN_RND_ov_flag) 
);
EXP_rounding #(
    .SIZE_DATA          (8) 
) EXP_RND (
    .i_carry_rounding   (MAN_RND_ov_flag),
    .i_exp_result       (EXP_ADJUST_exp_result),
    .o_exp_result       (EXP_RND_exp) 
);

assign w_exponent_result = PSC_sel_exp ? 8'hFF : EXP_RND_exp;
assign w_mantissa_result = PSC_sel_man[1] ? (PSC_sel_man[0] ? 23'b10000000000000000000000 : 23'h000000) : MAN_RND_man[22:0];

assign o_32_s = {w_sign_result, w_exponent_result, w_mantissa_result};
endmodule
