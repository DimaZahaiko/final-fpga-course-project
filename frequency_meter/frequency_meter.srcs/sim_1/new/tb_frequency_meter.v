`timescale 1ns / 1ps

module tb_frequency_meter;
    reg aclk =0;
    reg aresetn;
    reg sig_in = 0;
    
    reg [3:0] awaddr;
    reg awvalid;
    wire awready;
    
    reg [31:0] wdata;
    reg [3:0] wstrb;
    reg wvalid;
    wire wready;
    
    wire [1:0] bresp;
    wire bvalid;
    reg bready;
    
    reg [3:0] araddr;
    reg arvalid; 
    wire arready;
    
    wire [31:0] rdata;
    wire [1:0] rresp;
    wire rvalid; 
    reg rready;
    
    freq_meter_ip dut(
    .s_axi_aclk(aclk),
    .s_axi_aresetn(aresetn),
    .s_axi_awaddr(awaddr),
    .s_axi_awvalid(awvalid),
    .s_axi_awready(awready),
    .s_axi_wdata(wdata),
    .s_axi_wstrb(wstrb),
    .s_axi_wvalid(wvalid),
    .s_axi_wready(wready),
    .s_axi_bresp(bresp),
    .s_axi_bvalid(bvalid),
    .s_axi_bready(bready),
    .s_axi_araddr(araddr),
    .s_axi_arvalid(arvalid),
    .s_axi_arready(arready),
    .s_axi_rdata(rdata),
    .s_axi_rresp(rresp),
    .s_axi_rvalid(rvalid),
    .s_axi_rready(rready),
    .sig_in(sig_in)
    );
    
    //integer clk_period = 5;
    //integer sig_over_clk_period = 5*100;
    
    always #5 aclk = ~aclk;
    //always #500 sig_in = ~sig_in;
    
    task automatic freq_meter_check(input [31:0] data, input integer period_clks, input integer expected); begin
        awaddr = 4'b0; awvalid = 1'b1; //запис window
        wdata = data; wvalid = 1'b1;
        araddr = 4'hc; arvalid = 1;   //запитуємо статус
        rready = 1'b0; 
        wait(wready);
        awvalid = 1'b0; wvalid = 1'b0;
        @(posedge aclk); #1;
        awaddr = 4'd4; awvalid = 1'b1; //запис ctrl
        wdata = 32'b1; wvalid = 1'b1;

        //$display("status = %h", rdata);
        wait(rvalid); rready = 1'b1;
        @(posedge aclk); #1; wvalid = 1'b0;
        //$display("STATUS = %h", rdata);
        @(posedge aclk); #1;
        while (rdata == 0) begin        //поки статус нуль вхідний сигнал запущено з відповідною частотою
            sig_in = 0;
            repeat(period_clks/2) @(posedge aclk);
            sig_in = 1;
            repeat(period_clks/2) @(posedge aclk);
        end
        $display("TIME = %0d, status = %0d", $time, rdata);
        awvalid = 1'b0; wvalid = 1'b0;
        //@(posedge aclk); #1
        araddr = 4'h8; arvalid = 1'b1;  // read count
        rready = 1'b1;
        wait (rvalid);
        if (rdata == expected) $display("Measurment is complete. The counted value is %h", rdata);
        else $display("ERROR. Got %d, insted of %d", rdata, expected);
        rready = 1'b1;
    end
    endtask
    
    initial begin
        awvalid = 0;
        wvalid  = 0;
        arvalid = 0;
        rready  = 0;
        awaddr  = 0;
        wdata   = 0;
        araddr  = 0;
        aresetn = 0;
        #50;
        aresetn = 1;
        wstrb = 4'b1111;
        freq_meter_check(32'd1000, 100, 10);
        freq_meter_check(32'd2000, 40, 50);
        freq_meter_check(32'd250, 100, 2);
        #1000;
        $finish;
    end
    
    
    initial begin
    #50000;
    $display("TIMEOUT");
    $finish;
    end
    
endmodule
