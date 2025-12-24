task automatic Gen_CLOCK(
    output logic t_clk,
    input  int    PERIOD
);
begin
    fork
        t_clk = 0;
        forever #(PERIOD/2) t_clk = ~t_clk;
    join_none
end
endtask
