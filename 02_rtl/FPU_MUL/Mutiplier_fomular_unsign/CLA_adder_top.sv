module CLA_adder_top #(
    parameter WIDTH = 9,
    parameter FANIN = 4
)(
    input  wire [WIDTH-1:0] A,
    input  wire [WIDTH-1:0] B,
    input  wire             C_in,
    output wire [WIDTH-1:0]   Sum,
    output wire             C_out
);

    wire [WIDTH-1:0] P, G;
    wire [WIDTH:0]   C;

    // Generate P và G
    assign P = A ^ B;
    assign G = A & B;

    // CLA Tree
    cla_logic_tree_level #(
        .WIDTH(WIDTH),
        .FANIN(FANIN)
    ) cla_tree (
        .C_in(C_in),
        .P_in(P),
        .G_in(G),
        .C_out(C)
    );

    // Tính Sum
    assign Sum[WIDTH-1:0] = P ^ C[WIDTH-1:0];
    assign C_out = C[WIDTH];
  //  assign Sum[WIDTH] = C_out;

endmodule