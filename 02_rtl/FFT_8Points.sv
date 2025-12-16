module FFT_8Points #(
    parameter NUM_POINTS    = 8 ,
    parameter SIZE_DATA     = 32
)(
    input logic                                     i_clk       ,
    input logic                                     i_rst_n     ,
    input logic                                     i_start     ,
    input wire  [NUM_POINTS-1:0][SIZE_DATA-1:0]     i_data      ,
    
    output reg [NUM_POINTS-1:0][SIZE_DATA-1:0]      o_data_re   ,
    output reg [NUM_POINTS-1:0][SIZE_DATA-1:0]      o_data_im   ,
    output logic                                    o_done              
);

endmodule
