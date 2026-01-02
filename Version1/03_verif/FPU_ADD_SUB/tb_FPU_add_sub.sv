`timescale 1ns/1ps
`include "./../FPU_ADD_SUB/lib/Cal_funs.svh"
`include "./../FPU_ADD_SUB/lib/display.svh"
`include "./../FPU_ADD_SUB/lib/gen_clock.svh"

// `ifdef GATELEVEL
//     `include "./../../05_synth/Genus/Genus/FPU_unit_netlist.v"
//     `include "./../../05_synth/slow_vdd1v2_basicCells_lvt.v"
// `endif // GATELEVEL
module tb_FPU_add_sub();
localparam ALU_OP       = 1;
localparam SIZE_ADDR    = 11;
localparam SIZE_DATA    = 32;
localparam SIZE_ROM     = 1 << SIZE_ADDR;
localparam FILE_TEST_A  = "./../FPU_ADD_SUB/FPU_list_B.txt";
localparam FILE_TEST_B  = "./../FPU_ADD_SUB/FPU_list_A.txt";

logic                   i_clk;
logic                   i_rst_n;
logic                   i_add_sub;
logic [SIZE_DATA-1:0]   i_32_a;
logic [SIZE_DATA-1:0]   i_32_b;
logic [SIZE_DATA-1:0]   o_32_s;
logic                   o_ov_flow;
logic                   o_un_flow;

logic [SIZE_ADDR-1:0]   w_i_addr;
logic [SIZE_DATA-1:0]   w_o_data_rom_a;
logic [SIZE_DATA-1:0]   w_o_data_rom_b;
logic [SIZE_DATA-1:0]   rom_A [0:SIZE_ROM-1];
logic [SIZE_DATA-1:0]   rom_B [0:SIZE_ROM-1];
initial begin
    $readmemh(FILE_TEST_A, rom_A);
    $readmemh(FILE_TEST_B, rom_B);
end
assign w_o_data_rom_a = rom_A[w_i_addr];
assign w_o_data_rom_b = rom_B[w_i_addr];

int test_count = 0;
int test_pass  = 0;

    FPU_add_sub #(
        .NUM_OP     (ALU_OP)
    ) DUT (
        .i_add_sub       (i_add_sub),
        .i_32_a          (i_32_a),
        .i_32_b          (i_32_b),
        .o_32_s          (o_32_s)
    );

initial begin
    i_clk = 1'b0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

// initial begin
//     $dumpfile("tb_FPU_unit.vcd");
//     $dumpvars(0, tb_FPU_unit);
// end
initial begin 
    $shm_open("tb_FPU_add_sub.shm");
    $shm_probe("ASM");
end

task automatic Display_result_Error (
    string                      t_type      ,
    input logic                 t_i_add_sub ,
    input logic [31:0]          t_i_32_a    ,
    input logic [31:0]          t_i_32_b    ,
    input logic [31:0]          t_o_32_s    ,
    input logic                 t_o_ov_flow ,
    input logic                 t_o_un_flow  
);

    logic [31:0] t_o_32_e;
    shortreal t_sr_32_a, t_sr_32_b, t_sr_32_s, t_sr_32_e, t_sr_rounding_error;
    shortreal t_error;
    logic f_t_check;

    begin
        t_error             = Error_standard();
        t_sr_32_a           = HEX_TO_REAL(t_i_32_a);
        t_sr_32_b           = HEX_TO_REAL(t_i_32_b);
        t_sr_32_s           = HEX_TO_REAL(t_o_32_s);
        t_sr_32_e           = Cal_FPU_expected(t_i_add_sub, t_sr_32_a, t_sr_32_b);
        t_o_32_e            = REAL_TO_HEX(t_sr_32_e);
        t_sr_rounding_error = Error_actual(t_sr_32_s, t_sr_32_e);
        f_t_check           = (t_sr_rounding_error <= t_error) ? 1'b1 : 1'b0;

        $display("[%s][%s]i_32_a=%h (%.24f) %s i_32_b=%h (%.24f) \t| o_32_s=%h (%.24f) \t| o_ov_flow=%b, o_un_flow=%b",
                    t_type, (t_i_add_sub == 1'b1) ? "SUB" : "ADD", 
                    t_i_32_a, t_sr_32_a, (t_i_add_sub == 1'b1) ? "-" : "+", t_i_32_b, t_sr_32_b, t_o_32_s, t_sr_32_s,
                    t_o_ov_flow, t_o_un_flow);
        $display("=> %s: expect=%.24f (%h), dut=%.24f (%h), rounding_error=%.8f %% (exp_error = %.8f %%)", 
                    (f_t_check) ? "PASS" : "FAIL", 
                    t_sr_32_e, t_o_32_e, t_sr_32_s, t_o_32_s, t_sr_rounding_error, t_error);
        
        if (f_t_check) test_pass++;
        test_count++;
    end
endtask
task automatic Display_result_Similar (
    string                      t_type      ,
    input logic                 t_i_add_sub ,
    input logic [31:0]          t_i_32_a    ,
    input logic [31:0]          t_i_32_b    ,
    input logic [31:0]          t_o_32_s    ,
    input logic                 t_o_ov_flow ,
    input logic                 t_o_un_flow  
);
    logic [31:0] t_o_32_e;
    shortreal t_sr_32_a, t_sr_32_b, t_sr_32_s, t_sr_32_e, t_sr_rounding_error;
    shortreal t_error;
    logic f_t_check;

    begin
        t_error             = Error_standard();
        t_sr_32_a           = HEX_TO_REAL(t_i_32_a);
        t_sr_32_b           = HEX_TO_REAL(t_i_32_b);
        t_sr_32_s           = HEX_TO_REAL(t_o_32_s);
        t_sr_32_e           = Cal_FPU_expected(t_i_add_sub, t_sr_32_a, t_sr_32_b);
        t_o_32_e            = REAL_TO_HEX(t_sr_32_e);
        t_sr_rounding_error = Error_actual(t_sr_32_s, t_sr_32_e);
        f_t_check           = Is_Similar(t_o_32_s, t_o_32_e) ? 1'b1 : 1'b0;

        $display("[%s][%s]i_32_a=%h (%.24f) %s i_32_b=%h (%.24f) \t| o_32_s=%h (%.24f) \t| o_ov_flow=%b, o_un_flow=%b",
                    t_type, (t_i_add_sub == 1'b1) ? "SUB" : "ADD", 
                    t_i_32_a, t_sr_32_a, (t_i_add_sub == 1'b1) ? "-" : "+", t_i_32_b, t_sr_32_b, t_o_32_s, t_sr_32_s,
                    t_o_ov_flow, t_o_un_flow);
        $display("=> %s: expect=%.24f (%h), dut=%.24f (%h), rounding_error=%.8f %% (exp_error = %.8f %%)", 
                    (f_t_check) ? "PASS" : "FAIL", 
                    t_sr_32_e, t_o_32_e, t_sr_32_s, t_o_32_s, t_sr_rounding_error, t_error);
        
        if (f_t_check) test_pass++;
        test_count++;
    end

endtask
task automatic TestCase_Display_result(
    string              t_type,
    string              t_testcase,
    input logic [31:0]  t_i_fpu_a,
    input logic [31:0]  t_i_fpu_b
);
    begin
        $display("==========[ %s ]==========", t_testcase);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b0;
        i_32_a      = t_i_fpu_a;
        i_32_b      = t_i_fpu_b;
        o_ov_flow   = 1'b0;
        o_un_flow   = 1'b0;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b0;
        i_32_a      = t_i_fpu_b;
        i_32_b      = t_i_fpu_a;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b1;
        i_32_a      = t_i_fpu_a;
        i_32_b      = t_i_fpu_b;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b1;
        i_32_a      = t_i_fpu_b;
        i_32_b      = t_i_fpu_a;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
    end
endtask //automatic

task automatic TestCase_Display_result_Float(
    string              t_type,
    string              t_testcase,
    input shortreal     t_i_fpu_a,
    input shortreal     t_i_fpu_b
);

    logic [31:0] t_hex_fpu_a;
    logic [31:0] t_hex_fpu_b;
    t_hex_fpu_a = REAL_TO_HEX(t_i_fpu_a);
    t_hex_fpu_b = REAL_TO_HEX(t_i_fpu_b);
    begin
        $display("==========[ %s ]==========", t_testcase);
        $display("FPU_A = %h (%.4f)", t_hex_fpu_a, t_i_fpu_a);
        $display("FPU_B = %h (%.4f)", t_hex_fpu_b, t_i_fpu_b);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b0;
        i_32_a      = t_hex_fpu_a;
        i_32_b      = t_hex_fpu_b;
        o_ov_flow   = 1'b0;
        o_un_flow   = 1'b0;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b0;
        i_32_a      = t_hex_fpu_b;
        i_32_b      = t_hex_fpu_a;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b1;
        i_32_a      = t_hex_fpu_a;
        i_32_b      = t_hex_fpu_b;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        @(posedge i_clk);
        #1;
        i_add_sub   = 1'b1;
        i_32_a      = t_hex_fpu_b;
        i_32_b      = t_hex_fpu_a;
        @(negedge i_clk);
        #1;
        Display_result_Error(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
        // Display_result_Similar(t_type, i_add_sub, i_32_a, i_32_b, o_32_s, o_ov_flow, o_un_flow);
    end
endtask 

initial begin
    i_rst_n = 0;
    i_add_sub       = 1'b0;
    i_32_a          = 32'h0;
    i_32_b          = 32'h0;
    w_i_addr        = '0;
    #100;
    i_rst_n = 1;
    #100;
    TestCase_Display_result("ZERO", "(0.0 & 0.0)", 32'h00000000, 32'h00000000);
    TestCase_Display_result("ZERO", "(0.0 & -0.0)", 32'h00000000, 32'h80000000);
    TestCase_Display_result("ZERO", "(0.0 & -0.0)", 32'h4016A197, 32'h4016A197);
    TestCase_Display_result("ZERO", "(0.0 & -0.0)", 32'h40AED834, 32'h40AED834);
    TestCase_Display_result("INF", "(inf & inf)", 32'h7f800000, 32'h7f800000);
    TestCase_Display_result("INF", "(-inf & -inf)", 32'hff800000, 32'hff800000);
    TestCase_Display_result("INF", "(inf & -inf)", 32'hff800000, 32'h7f800000);
    TestCase_Display_result("INF", "(inf & 0)", 32'h7f800000, 32'h00000000);
    TestCase_Display_result("INF", "(-inf & 0)", 32'hff800000, 32'h00000000);
    TestCase_Display_result("INF", "(inf & Number)", 32'h7f800000, 32'h40533333);
    TestCase_Display_result("INF", "(-inf & Number)", 32'hff800000, 32'h40533333);
    TestCase_Display_result("INF", "(inf & -Number)", 32'h7f800000, 32'hc00ccccd);
    TestCase_Display_result("INF", "(-inf & -Number)", 32'hff800000, 32'hc00ccccd);
    TestCase_Display_result("NaN", "(NaN & -Number)", 32'h7f800001, 32'hc00ccccd);
    TestCase_Display_result("NaN", "(-NaN & -Number)", 32'hff800001, 32'hc00ccccd);
    TestCase_Display_result("NaN", "(NaN &  Number)", 32'hff800001, 32'h40533333);
    TestCase_Display_result("NaN", "(-NaN &  Number)", 32'h7f800001, 32'h40533333);
    TestCase_Display_result("APPRO", "APPR INF", 32'h7f21616f, 32'h007fffff);
    TestCase_Display_result("APPRO", "APPR INF", 32'h7f7fffff, 32'h00ffffff);
    TestCase_Display_result("APPRO", "APPR INF", 32'h7f7fffff, 32'h007fffff);
    TestCase_Display_result("APPRO", "APPR ZERO", 32'h00ffffff, 32'h007fffff);
    TestCase_Display_result("APPRO", "APPR ZERO", 32'h00ffffff, 32'h00ffffff);
    TestCase_Display_result("SIGN", "(-A + B)", 32'hc00ccccd, 32'h40533333);
    TestCase_Display_result("SIGN", "TEST SIGN", 32'hc00ccccd, 32'hc0533333);
    TestCase_Display_result("SIGN", "TEST SIGN", 32'hc00ccccd, 32'hc1b1999a);
    TestCase_Display_result("PRE_NOR_EXP", "Overflow rouding", 32'h0cffffff, 32'h00f80000);
    TestCase_Display_result("VALUE", "Value", 32'h5203778f, 32'h5018c9da);
    // // repeat(2**SIZE_ADDR) begin
    repeat(10) begin
        TestCase_Display_result("Random", "Read data from ROM", w_o_data_rom_a, w_o_data_rom_b);
        @(posedge i_clk);
        #1;
        w_i_addr = w_i_addr + 1;
    end

    TestCase_Display_result_Float("ADD", "ADD_POS_POS", 1.5, 2.25);
    TestCase_Display_result_Float("ADD", "ADD_NEG_NEG", -1.5, -2.25);
    TestCase_Display_result_Float("ADD", "ADD_POS_NEG", 5.0, -3.0);
    TestCase_Display_result_Float("ADD", "ADD_NEG_POS", -5.0, 3.0);
    TestCase_Display_result_Float("ADD", "ADD_ZERO", 3.14, 0.0);
    TestCase_Display_result_Float("ADD", "ADD_ZERO_REV", 0.0, -2.7);
    TestCase_Display_result_Float("ADD", "ADD_CANCEL_1", 5.0, -5.0);
    TestCase_Display_result_Float("ADD", "ADD_CANCEL_2", -100.25, 100.25);
    TestCase_Display_result_Float("ADD", "ADD_EXP_DIFF_1", 1.0e20, 1.0);
    TestCase_Display_result_Float("ADD", "ADD_EXP_DIFF_2", 1.0, 1.0e-20);
    TestCase_Display_result_Float("ADD", "ADD_DENORM_1", 1.0e-45, 1.0e-45);
    TestCase_Display_result_Float("ADD", "ADD_DENORM_2", 1.0e-45, 0.0);
    TestCase_Display_result_Float("ADD", "ADD_OVERFLOW", 3.4e38, 3.4e38);
    TestCase_Display_result_Float("ADD", "ADD_UNDERFLOW", 1.0e-38, -1.0e-38);
    TestCase_Display_result_Float("ADD", "ADD_INF", 1.0/0.0, 5.0);
    TestCase_Display_result_Float("ADD", "ADD_INF_NEG", -1.0/0.0, 2.0);
    TestCase_Display_result_Float("ADD", "ADD_INF_INF", 1.0/0.0, 1.0/0.0);
    TestCase_Display_result_Float("ADD", "ADD_INF_NINF", 1.0/0.0, -1.0/0.0);
    TestCase_Display_result_Float("ADD", "ADD_NAN_1", 0.0/0.0, 1.0);
    TestCase_Display_result_Float("ADD", "ADD_NAN_2", 0.0/0.0, 0.0/0.0);

    Display_SummaryResult(test_count, test_pass);
    #100;
    $finish;
end

endmodule
