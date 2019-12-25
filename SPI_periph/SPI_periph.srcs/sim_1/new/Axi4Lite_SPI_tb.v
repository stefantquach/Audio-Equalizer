`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2019 02:00:28 PM
// Design Name: 
// Module Name: Axi4Lite_SPI_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Axi4Lite_SPI_tb();

// USE SPI_DATA_WIDTH = 16 for ADC and SPI_DATA_WIDTH = 24 for DAC
parameter C_S_AXI_ADDR_WIDTH = 4, C_S_AXI_DATA_WIDTH = 32, SPI_DATA_WIDTH = 16/*SPI_DATA_WIDTH = 24*/, SPI_COUNTER_WIDTH = 10, CLK_PERIOD = 33.33 ;

// Axi4Lite signals
reg  S_AXI_ACLK ;
reg  S_AXI_ARESETN ;
wire [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR ;
wire  S_AXI_AWVALID ;
wire S_AXI_AWREADY ;
wire  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA ;
wire  [3:0] S_AXI_WSTRB ;
wire  S_AXI_WVALID ;
wire S_AXI_WREADY ;
wire [1:0] S_AXI_BRESP ;
wire S_AXI_BVALID ;
wire  S_AXI_BREADY ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR ;
wire  S_AXI_ARVALID ;
wire S_AXI_ARREADY ;
wire [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA ;
wire [1:0] S_AXI_RRESP ;
wire S_AXI_RVALID ;
wire  S_AXI_RREADY ;
// Simple Bus signals
reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
reg                                 wr ;
wire                                wrDone ;
reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData ;
reg                                 rd ;
wire                                rdDone ;

Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteManager1
    (
        // Simple Bus
        .wrAddr(wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
        .wrData(wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
        .wr(wr),                            // input    
        .wrDone(wrDone),                    // output
        .rdAddr(rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
        .rdData(rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
        .rd(rd),                            // input
        .rdDone(rdDone),                    // output
        // Axi4Lite Bus
        .M_AXI_ACLK(S_AXI_ACLK),            // input
        .M_AXI_ARESETN(S_AXI_ARESETN),      // input
        .M_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
        .M_AXI_AWVALID(S_AXI_AWVALID),      // output
        .M_AXI_AWREADY(S_AXI_AWREADY),      // input
        .M_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
        .M_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
        .M_AXI_WVALID(S_AXI_WVALID),        // output
        .M_AXI_WREADY(S_AXI_WREADY),        // input
        .M_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
        .M_AXI_BVALID(S_AXI_BVALID),        // input
        .M_AXI_BREADY(S_AXI_BREADY),        // output
        .M_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
        .M_AXI_ARVALID(S_AXI_ARVALID),      // output
        .M_AXI_ARREADY(S_AXI_ARREADY),      // input
        .M_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
        .M_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
        .M_AXI_RVALID(S_AXI_RVALID),        // input
        .M_AXI_RREADY(S_AXI_RREADY)         // output
    );    

wire SCK, SDI, SDO, CS;

Axi4Lite_SPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .SPI_COUNTER_WIDTH(SPI_COUNTER_WIDTH)) Axi4Lite_SPI1
(
        // SPI Signals
        .SCK(SCK),
        .SDO(SDO),
        .SDI(SDI),
        .CS(CS),
        // AXI Signals
        .S_AXI_ACLK(S_AXI_ACLK),            // input
        .S_AXI_ARESETN(S_AXI_ARESETN),      // input
        .S_AXI_AWADDR(S_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
        .S_AXI_AWVALID(S_AXI_AWVALID),      // output
        .S_AXI_AWREADY(S_AXI_AWREADY),      // input
        .S_AXI_WDATA(S_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
        .S_AXI_WSTRB(S_AXI_WSTRB),          // output   [3:0]
        .S_AXI_WVALID(S_AXI_WVALID),        // output
        .S_AXI_WREADY(S_AXI_WREADY),        // input
        .S_AXI_BRESP(S_AXI_BRESP),          // input    [1:0]
        .S_AXI_BVALID(S_AXI_BVALID),        // input
        .S_AXI_BREADY(S_AXI_BREADY),        // output
        .S_AXI_ARADDR(S_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
        .S_AXI_ARVALID(S_AXI_ARVALID),      // output
        .S_AXI_ARREADY(S_AXI_ARREADY),      // input
        .S_AXI_RDATA(S_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
        .S_AXI_RRESP(S_AXI_RRESP),          // input    [1:0]
        .S_AXI_RVALID(S_AXI_RVALID),        // input
        .S_AXI_RREADY(S_AXI_RREADY)         // output
);

AdcTester #() AdcTester1 (
    .SCK(SCK),
    .SDO(SDO),
    .SDI(SDI),
    .CS_(CS)
);

//DacTester#() DacTester1 (
//    .SCK(SCK),
//    .SDO(SDO),
//    .SDI(SDI),
//    .CS_(CS)
//);

parameter TestSineWaveFileL = "EqSine1.tb";
parameter TestSineWaveFileR = "EqSine2.tb";
parameter INPUT_LEN = 1000 ; 

reg [15:0] TestSineWaveChannelL[0:INPUT_LEN-1] ;
reg [15:0] TestSineWaveChannelR[0:INPUT_LEN-1] ;

parameter CLK_PERIOD_2 = (CLK_PERIOD/2) ;

integer i;

always begin
    #CLK_PERIOD_2 S_AXI_ACLK = ~S_AXI_ACLK ;
end

initial begin
    // Initial stuff
    
    $readmemh(TestSineWaveFileL,TestSineWaveChannelL);
    $readmemh(TestSineWaveFileR,TestSineWaveChannelR);
    
    S_AXI_ARESETN = 0 ;
    S_AXI_ACLK = 0;
    rdAddr = 0 ;
    rd = 0;
    wrAddr = 0;
    wrData = 0;
    wr = 0;
    #(CLK_PERIOD*20)
    #(CLK_PERIOD*2 + CLK_PERIOD_2+2) 
    S_AXI_ARESETN = 1 ;
    #(CLK_PERIOD*10) ;
    
    // ADC Stuff
    // Write wait cycles
    wr = 1;
    wrAddr = 12;
    wrData = 16;
    #CLK_PERIOD
    wr = 0;
    wrAddr = 0;
    wrData = 0;
    
    #(CLK_PERIOD*2)
    
    wr = 1;
    wrAddr = 4;
    wrData = 600;
    #CLK_PERIOD
    wr = 0;
    wrAddr = 0;
    wrData = 0;
    
    #(CLK_PERIOD*5)

    // Select channel
    wr = 1;
    wrAddr = 0;
    wrData = 'h8000;
    #CLK_PERIOD
    wr = 0;
    wrAddr = 0;
    
    #(CLK_PERIOD*2)
    
    while(1) begin
        rd = 1;
        while(~rdData[SPI_DATA_WIDTH]) begin
            #CLK_PERIOD;
        end
        $display("Converted: %x", rdData[15:0]);
        rd = 0;
        wr = 1;
        wrAddr = 8;
        wrData = 1;
        #(CLK_PERIOD * 2)
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        #CLK_PERIOD
        wr = 1;
        wrAddr = 0;
        wrData = wrData ^ 'h4000;
        #CLK_PERIOD
        wr = 0;
    end

    // DAC Stuff
    // Write wait cycles
//    wr = 1;
//    wrAddr = 1;
//    wrData = 600;
//    #CLK_PERIOD
//    wr = 0;
//    wrAddr = 0;
//    wrData = 0;
    
//    #(CLK_PERIOD*5)
    
//    // Write data
//    for (i = 0; i < INPUT_LEN; i = i+1) begin
//        #CLK_PERIOD
//        wr = 1;
//        wrAddr = 0;
//        wrData[SPI_DATA_WIDTH-1:SPI_DATA_WIDTH-8] = 'h30;
//        wrData[SPI_DATA_WIDTH-9:0] = TestSineWaveChannelL[i][15:0];
//        #CLK_PERIOD
//        wr = 0;
//        rd = 1;
//        while(~rdData[SPI_DATA_WIDTH]) begin
//            #CLK_PERIOD;
//        end
//        rd = 0;
//        #CLK_PERIOD
//        wr = 1;
//        wrAddr = 0;
//        wrData[SPI_DATA_WIDTH-1:SPI_DATA_WIDTH-8] = 'h31;
//        wrData[SPI_DATA_WIDTH-9:0] = TestSineWaveChannelR[i][15:0];
//        #CLK_PERIOD
//        wr = 0;
//        rd = 1;
//        while(~rdData[SPI_DATA_WIDTH]) begin
//            #CLK_PERIOD;
//        end
//        rd = 0;
//    end
    
end
endmodule
