`timescale 1ns / 1ps

module tb_system;   

    reg diff_clock_rtl_0_clk_p = 0;
    wire diff_clock_rtl_0_clk_n = ~diff_clock_rtl_0_clk_p;
    always #5 diff_clock_rtl_0_clk_p = ~diff_clock_rtl_0_clk_p;  // 100 МГц

    reg reset_rtl_0 = 0;   // reset активний 
    reg sig_in;
    design_1_wrapper dut(
        .diff_clock_rtl_clk_n(diff_clock_rtl_0_clk_n),
        .diff_clock_rtl_clk_p(diff_clock_rtl_0_clk_p),
        .reset_rtl(reset_rtl_0),
        .sig_in_0(sig_in)
    );
    
    always #15 sig_in = ~sig_in;
    
    initial begin
        reset_rtl_0 = 0;
        #30000;
        reset_rtl_0 = 1;
        #1000000;
        $finish;
    end
    
endmodule
