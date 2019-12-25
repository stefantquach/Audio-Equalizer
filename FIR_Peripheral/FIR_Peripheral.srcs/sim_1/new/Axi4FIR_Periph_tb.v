`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2019 05:35:01 PM
// Design Name: 
// Module Name: FIR_Periph_tb
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

module Axi4FIR_Periph_tb( );

parameter C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33 ;
parameter DATA_WIDTH = 16;
parameter NUM_TAPS = 279, NUM_FILTERS=13, NUM_SAMPLES = 1000;
parameter C_S_AXI_ADDR_WIDTH = $clog2(NUM_TAPS*NUM_FILTERS)+$clog2(C_S_AXI_DATA_WIDTH/8);

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
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData;
reg                                 rd ;
wire                                rdDone ;

// emulating the microblaze
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

// ADC signals
wire ADC_SCK, ADC_SDO, ADC_SDI, ADC_CS;

// DAC signals
wire DAC_SCK, DAC_SDO, DAC_SDI, DAC_CS;




// ADC instantiation
AdcTester AdcTester1(
    .SCK(ADC_SCK),
    .SDO(ADC_SDO),
    .SDI(ADC_SDI),
    .CS_(ADC_CS)
);
// DAC instantiation
DacTester DacTester1(
    .SCK(DAC_SCK),
    .SDO(DAC_SDO),
    .SDI(DAC_SDI),
    .CS_(DAC_CS)
);

// Axi4Lite equalizer instantiation
Axi4Lite_Equalizer #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .DATA_WIDTH(DATA_WIDTH), .NUM_FILTERS(NUM_FILTERS), .NUM_TAPS(NUM_TAPS)) eq (
    // Axi bus to Microblaze
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
    .S_AXI_RREADY(S_AXI_RREADY),        // input
    
    .ADC_SCK(ADC_SCK),
    .ADC_SDO(ADC_SDO),
    .ADC_SDI(ADC_SDI),
    .ADC_CS(ADC_CS),
    .DAC_SCK(DAC_SCK),
    .DAC_SDO(DAC_SDO),
    .DAC_SDI(DAC_SDI),
    .DAC_CS(DAC_CS)
);

parameter CLK_PERIOD_2 = CLK_PERIOD/2;

reg [C_S_AXI_DATA_WIDTH/2-1:0] atten [NUM_FILTERS-1:0];
reg [C_S_AXI_DATA_WIDTH/2-1:0] h [NUM_FILTERS-1:0][NUM_TAPS-1:0];

integer i;

always begin
    #CLK_PERIOD_2 S_AXI_ACLK = ~S_AXI_ACLK;
end

initial begin
    S_AXI_ARESETN = 0;
    S_AXI_ACLK = 0;
    rdAddr = 0 ;
    rd = 0 ;
    wrAddr = 0 ;
    wrData = 0 ;
    wr = 0 ;
    
    #(CLK_PERIOD_2+2) S_AXI_ARESETN = 1 ;
    
    $readmemh("tapshex.csv", h);
    $readmemh("attenuations.csv", atten);
    #(CLK_PERIOD*10);
    // waiting until the FIR peripheral is ready
    rd = 1;
    while(!(rdData == 1 && rdDone)) begin
        #CLK_PERIOD;
    end
    rd = 0;
    #CLK_PERIOD;
    // writing taps
    for(i=0; i<NUM_TAPS*NUM_FILTERS; i=i+1) begin
        wr = 1;
        wrAddr = i*4;
        wrData = h[i/NUM_TAPS][i%NUM_TAPS];
        #CLK_PERIOD
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        #(CLK_PERIOD*2);
    end
    
    $display("finished writing taps");
    #(CLK_PERIOD*10);
    // writing attenuations
    for(i=0; i<NUM_FILTERS; i=i+1)begin
        wr = 1;
        wrAddr = 4*(NUM_TAPS*NUM_FILTERS+i);
        wrData = 16'h4000;
        #CLK_PERIOD;
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        #(CLK_PERIOD*2);
    end
    
    $display("finished writing attenuations");
    
    // enabling
    #(CLK_PERIOD*2);
    wr = 1;
    wrAddr = 4*(NUM_TAPS*NUM_FILTERS+NUM_FILTERS);
    #CLK_PERIOD
    wr=0;
    wrAddr = 0;
    #(CLK_PERIOD*10);
    
    $display("enabled");
    while(1) begin
        #CLK_PERIOD;
    end
    $stop;
end

endmodule
