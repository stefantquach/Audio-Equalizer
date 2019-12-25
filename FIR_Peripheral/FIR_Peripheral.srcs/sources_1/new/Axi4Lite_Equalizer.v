`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2019 01:30:38 PM
// Design Name: 
// Module Name: Axi4Lite_Equalizer
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


module Axi4Lite_Equalizer
#(parameter C_S_AXI_ADDR_WIDTH = 14, C_S_AXI_DATA_WIDTH = 32, DATA_WIDTH=16, NUM_FILTERS=13, NUM_TAPS=279) (
    // Axi4Lite Supporter Bus
    input       S_AXI_ACLK,
    input       S_AXI_ARESETN,
    input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
    input       S_AXI_AWVALID,
    output      S_AXI_AWREADY,
    input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
    input       [3:0] S_AXI_WSTRB,
    input       S_AXI_WVALID,
    output      S_AXI_WREADY,
    output      [1:0] S_AXI_BRESP,
    output      S_AXI_BVALID,
    input       S_AXI_BREADY,
    input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
    input       S_AXI_ARVALID,
    output      S_AXI_ARREADY,
    output      [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
    output      [1:0] S_AXI_RRESP,
    output      S_AXI_RVALID,
    input       S_AXI_RREADY,
    
    // SPI signals for ADC
    output      ADC_SCK,
    output      ADC_SDI,
    input       ADC_SDO,
    output      ADC_CS,
    
    // SPI signals for DAC
    output      DAC_SCK,
    output      DAC_SDI,
    input       DAC_SDO,
    output      DAC_CS
);
// Simple Bus signals
wire     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
wire     [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
wire                                 wr ;
wire     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData;
wire                                 rd ;
// Axi4Lite Supporter instantiation
Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
    // Simple Bus
    .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wr),                            // output
    .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdData),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .rd(rd),                            // output   
    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(S_AXI_AWVALID),      // input
    .S_AXI_AWREADY(S_AXI_AWREADY),      // output
    .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
    .S_AXI_WVALID(S_AXI_WVALID),        // input
    .S_AXI_WREADY(S_AXI_WREADY),        // output        
    .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
    .S_AXI_BVALID(S_AXI_BVALID),        // output
    .S_AXI_BREADY(S_AXI_BREADY),        // input
    .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_ARVALID(S_AXI_ARVALID),      // input
    .S_AXI_ARREADY(S_AXI_ARREADY),      // output
    .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
    .S_AXI_RVALID(S_AXI_RVALID),        // output    
    .S_AXI_RREADY(S_AXI_RREADY)         // input
) ; 
wire calc, calcDone, channel, enabled;
wire [DATA_WIDTH-1:0] rawData, filterData;

FIR_Periph #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .DATA_WIDTH(DATA_WIDTH), .NUM_FILTERS(NUM_FILTERS), .NUM_TAPS(NUM_TAPS)) FIR_Periph1 (
    .clk(S_AXI_ACLK),
    .calc(calc),
    .calcDone(calcDone),
    .channel(channel),
    .enabled(enabled),
    .rawData(rawData),
    .filterData(filterData),
    .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wr),                            // output
    .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdData),                    // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .rd(rd),                            // output   
    .reset_l(S_AXI_ARESETN)
);

// Axi4Lite signals (ADC)
wire [C_S_AXI_ADDR_WIDTH-1:0] ADC_AXI_AWADDR ;
wire  ADC_AXI_AWVALID ;
wire ADC_AXI_AWREADY ;
wire  [C_S_AXI_DATA_WIDTH-1:0] ADC_AXI_WDATA ;
wire  [3:0] ADC_AXI_WSTRB ;
wire  ADC_AXI_WVALID ;
wire ADC_AXI_WREADY ;
wire [1:0] ADC_AXI_BRESP ;
wire ADC_AXI_BVALID ;
wire  ADC_AXI_BREADY ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] ADC_AXI_ARADDR ;
wire  ADC_AXI_ARVALID ;
wire ADC_AXI_ARREADY ;
wire [C_S_AXI_DATA_WIDTH-1:0] ADC_AXI_RDATA ;
wire [1:0] ADC_AXI_RRESP ;
wire ADC_AXI_RVALID ;
wire  ADC_AXI_RREADY ;

// Axi4Lite signals (DAC)
wire [C_S_AXI_ADDR_WIDTH-1:0] DAC_AXI_AWADDR ;
wire  DAC_AXI_AWVALID ;
wire DAC_AXI_AWREADY ;
wire  [C_S_AXI_DATA_WIDTH-1:0] DAC_AXI_WDATA ;
wire  [3:0] DAC_AXI_WSTRB ;
wire  DAC_AXI_WVALID ;
wire DAC_AXI_WREADY ;
wire [1:0] DAC_AXI_BRESP ;
wire DAC_AXI_BVALID ;
wire  DAC_AXI_BREADY ;
wire  [C_S_AXI_ADDR_WIDTH-1:0] DAC_AXI_ARADDR ;
wire  DAC_AXI_ARVALID ;
wire DAC_AXI_ARREADY ;
wire [C_S_AXI_DATA_WIDTH-1:0] DAC_AXI_RDATA ;
wire [1:0] DAC_AXI_RRESP ;
wire DAC_AXI_RVALID ;
wire  DAC_AXI_RREADY ;

ADC_DAC_Controller #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .DATA_WIDTH(DATA_WIDTH)) Controller (
    .clk(S_AXI_ACLK),
    .reset_L(S_AXI_ARESETN),
    .calc(calc),
    .calcDone(calcDone),
    .channel(channel),
    .enabled(enabled),
    .rawData(rawData),
    .filterData(filterData),
    // Axi4Lite Bus
    .ADC_AXI_AWADDR(ADC_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
    .ADC_AXI_AWVALID(ADC_AXI_AWVALID),      // output
    .ADC_AXI_AWREADY(ADC_AXI_AWREADY),      // input
    .ADC_AXI_WDATA(ADC_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
    .ADC_AXI_WSTRB(ADC_AXI_WSTRB),          // output   [3:0]
    .ADC_AXI_WVALID(ADC_AXI_WVALID),        // output
    .ADC_AXI_WREADY(ADC_AXI_WREADY),        // input
    .ADC_AXI_BRESP(ADC_AXI_BRESP),          // input    [1:0]
    .ADC_AXI_BVALID(ADC_AXI_BVALID),        // input
    .ADC_AXI_BREADY(ADC_AXI_BREADY),        // output
    .ADC_AXI_ARADDR(ADC_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
    .ADC_AXI_ARVALID(ADC_AXI_ARVALID),      // output
    .ADC_AXI_ARREADY(ADC_AXI_ARREADY),      // input
    .ADC_AXI_RDATA(ADC_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
    .ADC_AXI_RRESP(ADC_AXI_RRESP),          // input    [1:0]
    .ADC_AXI_RVALID(ADC_AXI_RVALID),        // input
    .ADC_AXI_RREADY(ADC_AXI_RREADY),         // output
    
    // Axi4Lite Bus
    .DAC_AXI_AWADDR(DAC_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
    .DAC_AXI_AWVALID(DAC_AXI_AWVALID),      // output
    .DAC_AXI_AWREADY(DAC_AXI_AWREADY),      // input
    .DAC_AXI_WDATA(DAC_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
    .DAC_AXI_WSTRB(DAC_AXI_WSTRB),          // output   [3:0]
    .DAC_AXI_WVALID(DAC_AXI_WVALID),        // output
    .DAC_AXI_WREADY(DAC_AXI_WREADY),        // input
    .DAC_AXI_BRESP(DAC_AXI_BRESP),          // input    [1:0]
    .DAC_AXI_BVALID(DAC_AXI_BVALID),        // input
    .DAC_AXI_BREADY(DAC_AXI_BREADY),        // output
    .DAC_AXI_ARADDR(DAC_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
    .DAC_AXI_ARVALID(DAC_AXI_ARVALID),      // output
    .DAC_AXI_ARREADY(DAC_AXI_ARREADY),      // input
    .DAC_AXI_RDATA(DAC_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
    .DAC_AXI_RRESP(DAC_AXI_RRESP),          // input    [1:0]
    .DAC_AXI_RVALID(DAC_AXI_RVALID),        // input
    .DAC_AXI_RREADY(DAC_AXI_RREADY)         // output
);




// Axi4Lite Supporter instantiation (ADC)
Axi4Lite_SPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4Lite_ADC (
    .SCK(ADC_SCK),
    .SDO(ADC_SDO),
    .SDI(ADC_SDI),
    .CS(ADC_CS),
    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(ADC_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(ADC_AXI_AWVALID),      // input
    .S_AXI_AWREADY(ADC_AXI_AWREADY),      // output
    .S_AXI_WDATA(ADC_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_WSTRB(ADC_AXI_WSTRB),          // input    [3:0]
    .S_AXI_WVALID(ADC_AXI_WVALID),        // input
    .S_AXI_WREADY(ADC_AXI_WREADY),        // output        
    .S_AXI_BRESP(ADC_AXI_BRESP),          // output   [1:0]
    .S_AXI_BVALID(ADC_AXI_BVALID),        // output
    .S_AXI_BREADY(ADC_AXI_BREADY),        // input
    .S_AXI_ARADDR(ADC_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_ARVALID(ADC_AXI_ARVALID),      // input
    .S_AXI_ARREADY(ADC_AXI_ARREADY),      // output
    .S_AXI_RDATA(ADC_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_RRESP(ADC_AXI_RRESP),          // output   [1:0]
    .S_AXI_RVALID(ADC_AXI_RVALID),        // output    
    .S_AXI_RREADY(ADC_AXI_RREADY)         // input
) ; 

// Axi4Lite Supporter instantiation (DAC)
Axi4Lite_SPI #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4Lite_DAC (
    .SCK(DAC_SCK),
    .SDO(DAC_SDO),
    .SDI(DAC_SDI),
    .CS(DAC_CS),
    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(DAC_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(DAC_AXI_AWVALID),      // input
    .S_AXI_AWREADY(DAC_AXI_AWREADY),      // output
    .S_AXI_WDATA(DAC_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_WSTRB(DAC_AXI_WSTRB),          // input    [3:0]
    .S_AXI_WVALID(DAC_AXI_WVALID),        // input
    .S_AXI_WREADY(DAC_AXI_WREADY),        // output        
    .S_AXI_BRESP(DAC_AXI_BRESP),          // output   [1:0]
    .S_AXI_BVALID(DAC_AXI_BVALID),        // output
    .S_AXI_BREADY(DAC_AXI_BREADY),        // input
    .S_AXI_ARADDR(DAC_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_ARVALID(DAC_AXI_ARVALID),      // input
    .S_AXI_ARREADY(DAC_AXI_ARREADY),      // output
    .S_AXI_RDATA(DAC_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_RRESP(DAC_AXI_RRESP),          // output   [1:0]
    .S_AXI_RVALID(DAC_AXI_RVALID),        // output    
    .S_AXI_RREADY(DAC_AXI_RREADY)         // input
) ; 

endmodule
