task Display_SummaryResult(
    input int           t_test_count    ,
    input int           t_test_pass     
);
    begin
        #100;
            $display("\n==================================");
            $display("========== TEST SUMMARY ==========");
            $display("Total test cases: %6d", t_test_count);
            $display("Passed          : %6d", t_test_pass);
            $display("Failed          : %6d", t_test_count - t_test_pass);
            $display("Pass rate       : %0.2f%%", (t_test_pass * 100.0) / t_test_count);
            $display("==================================\n");
        #100;
    end
endtask
