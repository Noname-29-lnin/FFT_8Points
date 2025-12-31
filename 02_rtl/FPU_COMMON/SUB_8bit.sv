module SUB_8bit (
    input logic         i_carry,
    input  logic [7:0]  i_data_a,
    input  logic [7:0]  i_data_b,
    output logic [7:0]  o_sub,
    output logic        o_borrow
);

    logic [1:0] w_P, w_G;
    logic w_C;

    SUB_4bit SUB_4bit_0(
        .A        (i_data_a[3:0]),
        .B        (i_data_b[3:0]),
        .Bin      (i_carry),
        .SUB      (o_sub[3:0]),
        .Bout     (w_C) 
    );
    SUB_4bit SUB_4bit_1(
        .A        (i_data_a[7:4]),
        .B        (i_data_b[7:4]),
        .Bin      (w_C),
        .SUB      (o_sub[7:4]),
        .Bout     (o_borrow) 
    );

endmodule
