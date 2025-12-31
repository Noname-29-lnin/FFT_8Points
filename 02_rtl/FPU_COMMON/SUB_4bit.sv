module SUB_4bit (
    input  logic [3:0] A        ,
    input  logic [3:0] B        ,
    input  logic       Bin      ,
    output logic [3:0] SUB      ,
    output logic       Bout      
);

logic [3:0] g, p, b;
assign g = ~A &  B;
assign p = ~(A & ~B);
assign b[0] = g[0] | (p[0] & Bin);
assign b[1] = g[1] | (p[1] & b[0]);
assign b[2] = g[2] | (p[2] & b[1]);
assign b[3] = g[3] | (p[3] & b[2]);
assign SUB = A ^ B ^ {b[2:0], Bin};
assign Bout = b[3];

endmodule
