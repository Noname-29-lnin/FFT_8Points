module ADD_SUB_CLS_4bit (
    input  logic [3:0] A        ,
    input  logic [3:0] B        ,
    input  logic       Bin      ,
    output logic [3:0] SUB      ,
    output logic       Bout      
);

logic [3:0] g, b;
assign g = B;
assign b[0] = g[0] | (Bin);
assign b[1] = g[1] | (b[0]);
assign b[2] = g[2] | (b[1]);
assign b[3] = g[3] | (b[2]);
assign SUB = B ^ {b[2:0], Bin};
assign Bout = b[3];

endmodule
