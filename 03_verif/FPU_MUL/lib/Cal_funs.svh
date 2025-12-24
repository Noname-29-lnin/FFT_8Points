function automatic shortreal HEX_TO_REAL(
    input logic [31:0]  f_i_data
);
    int temp;
    begin
        temp = int'(f_i_data);
        return $bitstoshortreal(temp);
    end  
endfunction

function automatic logic [31:0] REAL_TO_HEX(
    input shortreal f_i_data
);
    begin
        return $shortrealtobits(f_i_data);
    end
endfunction

function automatic shortreal Cal_FPU_expected(
    input shortreal     f_i_32_a    ,
    input shortreal     f_i_32_b            
);
    begin
        return f_i_32_a * f_i_32_b;
    end
endfunction

function shortreal Error_standard();
    begin
        return ((2.0 ** (-23.0)) / 1.0) * 100.0;
    end
endfunction

function shortreal ABS_value(
    input shortreal f_i_value
);
    begin
        if(f_i_value < 0.0) begin
            return -f_i_value;
        end else begin
            return f_i_value;
        end
    end
endfunction

function automatic shortreal Error_actual(
    input shortreal         f_i_32_s    ,
    input shortreal         f_i_32_e     
);
    logic [31:0] f_t_32_s, f_t_32_e;
    logic is_E_one_S, is_E_one_E;
    logic is_M_zero_S, is_M_zero_E;
    logic is_INF_S, is_INF_E;
    logic is_NAN_S, is_NAN_E;

    begin
        f_t_32_s    = REAL_TO_HEX(f_i_32_s);
        f_t_32_e    = REAL_TO_HEX(f_i_32_e);
        is_E_one_S  = &f_t_32_s[30:23];
        is_M_zero_S = ~|f_t_32_s[22:0];
        is_INF_S    = is_E_one_S & is_M_zero_S;
        is_NAN_S    = is_E_one_S & ~is_M_zero_S;
        is_E_one_E  = &f_t_32_e[30:23];
        is_M_zero_E = ~|f_t_32_e[22:0];
        is_INF_E    = is_E_one_E & is_M_zero_E;
        is_NAN_E    = is_E_one_E & ~is_M_zero_E;

        if(is_NAN_S) begin
            Error_actual = (is_NAN_E) ? 0.0 : 100.0;
        end else if(is_NAN_E) begin
            Error_actual = (is_NAN_S) ? 0.0 : 100.0;
        end else if(is_INF_S || is_INF_E) begin
            Error_actual = (f_t_32_s == f_t_32_e) ? 0.0 : 100;
        end else if((f_i_32_e == 0.0) || (f_i_32_e == -0.0)) begin
            Error_actual = ((f_i_32_s == 0.0) || (f_i_32_s == -0.0)) ? 0.0 : 100.0;
        end else begin
            Error_actual = ((ABS_value(f_i_32_e - f_i_32_s)) / ABS_value(f_i_32_e)) * 100.0;
        end
    end
endfunction

function automatic logic Is_Similar(
    input logic [31:0]      f_i_32_s    ,
    input logic [31:0]      f_i_32_e     
);
    logic is_E_one_S, is_E_one_E;
    logic is_M_zero_S, is_M_zero_E;
    logic is_INF_S, is_INF_E;
    logic is_NAN_S, is_NAN_E;

    begin
        is_E_one_S  = &f_i_32_s[30:23];
        is_M_zero_S = ~|f_i_32_s[22:0];
        is_INF_S    = is_E_one_S & is_M_zero_S;
        is_NAN_S    = is_E_one_S & ~is_M_zero_S;
        is_E_one_E  = &f_i_32_e[30:23];
        is_M_zero_E = ~|f_i_32_e[22:0];
        is_INF_E    = is_E_one_E & is_M_zero_E;
        is_NAN_E    = is_E_one_E & ~is_M_zero_E;
        if(is_NAN_S) begin
            Is_Similar = (is_NAN_E) ? 1'b1 : 1'b0;
        end else if(is_INF_S) begin
            Is_Similar = (f_i_32_s == f_i_32_e) ? 1'b1 : 1'b0;
        end else begin
            Is_Similar = (f_i_32_s == f_i_32_e) ? 1'b1 : 1'b0;
        end
    end
endfunction