`timescale 1ns / 1ps

module freq_meter_ip(
    
    input wire s_axi_aclk, s_axi_aresetn,
    
    input wire [3:0] s_axi_awaddr,   //address to write a byte
    input wire s_axi_awvalid,   // is write adress valid
    output wire s_axi_awready,  // am ready to take address
    
    input wire [31:0] s_axi_wdata,   // data to be written
    input wire [3:0] s_axi_wstrb,   // маска валідних байтів
    input wire s_axi_wvalid,   // is data and strobes valid
    output wire s_axi_wready,  // am ready to write transaction
    
    output wire [1:0] s_axi_bresp,  // status of the write transaction
    output wire s_axi_bvalid,   // is status valid
    input wire s_axi_bready,   // master can take the response
    
    input wire [3:0] s_axi_araddr,   // address to read from
    input wire s_axi_arvalid,  // is read address valid
    output wire s_axi_arready,   // ready to accept address
    
    output wire [31:0] s_axi_rdata,   // data on the adress
    output wire [1:0] s_axi_rresp,   //the status of the read transfer
    output wire s_axi_rvalid, // is the data valid
    input wire s_axi_rready,  //master is ready to take the data
    
    input sig_in
    
    );
    
    reg [3:0]   axi_awaddr;
    reg         axi_awready;
    assign      s_axi_awready = axi_awready;
    reg         axi_wready;
    assign      s_axi_wready = axi_wready;
    reg [1:0]   axi_bresp;
    assign      s_axi_bresp = axi_bresp;
    reg         axi_bvalid;
    assign      s_axi_bvalid = axi_bvalid;
    reg [3:0]   axi_araddr;
    reg         axi_arready;
    assign      s_axi_arready = axi_arready;
    reg [1:0]   axi_rresp;
    assign      s_axi_rresp = axi_rresp;
    reg         axi_rvalid;
    assign      s_axi_rvalid = axi_rvalid;
    

    reg [31:0] window;
    reg ctrl;

    integer byte_index;
    
    
    //============ FREQUENCY METER LOGIC =============
    
    reg middle_sig_in, synch_sig_in;
    
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if (!s_axi_aresetn) begin
            middle_sig_in <= 1'b0;
            synch_sig_in  <= 1'b0;
        end
        else begin
            middle_sig_in <= sig_in;
            synch_sig_in  <= middle_sig_in;
        end
    end
    
    reg counting;
    reg [31:0] edge_count;
    reg [31:0] count;
    reg status;
    reg [31:0] timer;
    reg prev_sig;
    //reg sigposedge;
    
    always @(posedge s_axi_aclk or negedge s_axi_aresetn) begin
        if(!s_axi_aresetn) begin
            edge_count <= 32'b0;
            counting <= 0;
            count <= 32'b0;
            status <= 0;
            timer <= 32'b0;
            prev_sig <= 0;
        end
        else begin
            if(ctrl && !counting)begin
                counting <= 1;
                status <= 0;
                edge_count <= 32'b0;
            end
            else if(counting) begin
                if(timer < window) begin
                    timer <= timer +1;
                    if(!prev_sig && synch_sig_in) 
                        edge_count <= edge_count + 1;
                     
                end
                else begin
                    timer <= 32'b0;
                    counting <= 0;
                    status <= 1;
                    count <= edge_count;
                end
            end
            prev_sig <= synch_sig_in;
        end
    end
    
    //=========== WRITE State Mashine =======
    reg [1:0] state_write;
    localparam IDLE = 2'b0, WADDR = 2'd1, WDATA = 2'd2;
    
    reg [3:0] waddr_now;
    
    always @(posedge s_axi_aclk) begin
        if (!s_axi_aresetn) begin
             axi_awready <= 0;                                 
	         axi_wready <= 0;                                 
	         axi_bvalid <= 0;                                 
	         axi_bresp <= 0;
	         axi_awaddr <= 0;                                 
             state_write <= IDLE;
        end else case (state_write)
            IDLE: begin
                axi_awready <= 1'b1;
                axi_wready <= 1'b1;
                state_write <= WADDR;
            end
            WADDR: begin 
                if(s_axi_awvalid && s_axi_awready) begin
                    axi_awaddr <= s_axi_awaddr;
                    axi_wready <= 1'b0;
                    if(s_axi_wvalid) begin
                        axi_awready <= 1'b1;
                        state_write <= WADDR;
                        axi_bvalid <= 1'b1;
                    end else begin
                        axi_awready <= 1'b0;
                        state_write <= WDATA;
                        if (s_axi_bready && axi_bvalid) axi_bvalid <= 1'b0;
                    end
                end
                else begin
                    if (s_axi_bready && axi_bvalid) axi_bvalid <= 1'b0;
                end
            end
            WDATA: begin
                if(s_axi_wvalid) begin
                    axi_wready <= 1'b1;
                    state_write <= WADDR;
                    axi_bvalid <= 1'b1;
                    axi_awready <= 1'b1;
                end else begin
                    if(s_axi_bready && axi_bvalid) axi_bvalid <= 1'b0;
                end
            end
        endcase
    end
    
    always @(posedge s_axi_aclk) begin
        if(!s_axi_aresetn) begin
            window <= 32'b0;
            ctrl <= 1'b0;
        end 
        else begin
            if (counting) ctrl <= 1'b0;
            if (s_axi_wvalid) begin
                case(s_axi_awvalid ? s_axi_awaddr[3:2]: axi_awaddr[3:2])
                2'h0: begin 
                    for(byte_index = 0; byte_index < 4; byte_index = byte_index +1) begin
                        if (s_axi_wstrb[byte_index]) 
                            window[(byte_index*8) +: 8] <= s_axi_wdata[ (byte_index*8) +: 8];
                    end
                end
                2'h1: begin
                    if (s_axi_wstrb[0] && !counting) ctrl <= s_axi_wdata[0];
                end
                endcase
            end
        end
    end
    
    //============ READ state machine ==================
    localparam RADDR = 2'd1, RDATA = 2'd2;
    
    reg [1:0] state_read;
    
    always @(posedge s_axi_aclk)begin
        if(!s_axi_aresetn) begin
            axi_arready <= 1'b0;
            axi_rvalid <= 1'b0;
            axi_rresp <= 2'b00;
            state_read <= IDLE;
        end
        else begin
            case(state_read)
            IDLE: begin
                if(s_axi_aresetn) begin
                    state_read <= RADDR;
                    axi_arready <= 1'b1;
                end
            end
            RADDR: begin
                if(s_axi_arvalid && s_axi_arready) begin
                    state_read <= RDATA;
                    axi_araddr <= s_axi_araddr;
                    axi_rvalid <= 1'b1;
                    axi_arready <= 1'b0;
                end              
            end
            RDATA: begin
                if (s_axi_rvalid && s_axi_rready) begin
                    axi_rvalid <= 1'b0;
                    axi_arready <= 1'b1;
                    state_read <= RADDR;
                end
            end
            endcase
        end
    end
    
    assign s_axi_rdata = (axi_araddr[3:2] == 2'h0) ? window: (axi_araddr[3:2] == 2'h2) ? count : (axi_araddr[3:2] == 2'h3) ? {31'b0, status} : 0; 
    
endmodule
