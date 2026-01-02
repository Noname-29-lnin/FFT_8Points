module MUL_SHF_left #(
    parameter SIZE_DATA  = 32,
    parameter SIZE_SHIFT = 5  
)(
    input  logic [SIZE_SHIFT-1:0] i_shift_number,
    input  logic [SIZE_DATA-1:0]  i_data, 
    output logic [SIZE_DATA-1:0]  o_data
);

    logic [SIZE_DATA-1:0] stage [SIZE_SHIFT:0];

    // Stage 0 = input
    assign stage[0] = i_data;

    genvar i;
    generate
        for (i = 0; i < SIZE_SHIFT; i++) begin : GEN_SHIFT
            localparam SHIFT_AMT = (1 << i);

            assign stage[i+1] = i_shift_number[i] ? { stage[i][SIZE_DATA-1-SHIFT_AMT : 0], {SHIFT_AMT{1'b0}} } : stage[i];
        end
    endgenerate

    assign o_data = stage[SIZE_SHIFT];

endmodule
