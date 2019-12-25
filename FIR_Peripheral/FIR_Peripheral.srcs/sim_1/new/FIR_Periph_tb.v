`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2019 01:13:59 PM
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


module FIR_Periph_tb( );

parameter C_S_AXI_DATA_WIDTH = 32, CLK_PERIOD = 33.33 ;
parameter DATA_WIDTH = 16;
parameter NUM_TAPS = 279, NUM_FILTERS=13, NUM_SAMPLES = 1000;
parameter C_S_AXI_ADDR_WIDTH = $clog2(NUM_TAPS*NUM_FILTERS)+$clog2(C_S_AXI_DATA_WIDTH/8);

reg clk;
reg resetn;

reg calc;
wire calcDone;
reg channel;
reg [DATA_WIDTH-1:0] data;
wire signed [DATA_WIDTH-1:0] outputData;
wire enabled;

// Simple Bus signals
reg     [C_S_AXI_ADDR_WIDTH-1:0]    wrAddr ;
reg     [C_S_AXI_DATA_WIDTH-1:0]    wrData ;
reg                                 wr ;
reg     [C_S_AXI_ADDR_WIDTH-1:0]    rdAddr ;
wire    [C_S_AXI_DATA_WIDTH-1:0]    rdData;
reg                                 rd ;

FIR_Periph # (.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .DATA_WIDTH(DATA_WIDTH), .NUM_FILTERS(NUM_FILTERS), .NUM_TAPS(NUM_TAPS)) Periph1 (
    .clk(clk),
    .reset_l(resetn),
    .wrAddr(wrAddr),
    .wrData(wrData),
    .wr(wr),
    .rd(rd),
    .rdAddr(rdAddr),
    .rdData(rdData),
    .calc(calc),
    .calcDone(calcDone),
    .channel(channel),
    .rawData(data),
    .filterData(outputData),
    .enabled(enabled)
);

parameter CLK_PERIOD_2 = CLK_PERIOD/2;

reg [C_S_AXI_DATA_WIDTH/2-1:0] atten [NUM_FILTERS-1:0];

reg [C_S_AXI_DATA_WIDTH/2-1:0] h [NUM_FILTERS-1:0][NUM_TAPS-1:0];
reg [C_S_AXI_DATA_WIDTH/2-1:0] x_1 [NUM_SAMPLES-1:0];
reg [C_S_AXI_DATA_WIDTH/2-1:0] x_2 [NUM_SAMPLES-1:0];

always begin
    #CLK_PERIOD_2 clk = ~clk;
end

integer i;
initial begin
    resetn = 0;
    clk = 0;
    rdAddr = 0 ;
    rd = 0 ;
    wrAddr = 0 ;
    wrData = 0 ;
    wr = 0 ;
    
    calc = 0;
    channel = 0;
    data = 0;
    
    #(CLK_PERIOD_2+2) resetn = 1;
    rd = 1;
    while(rdData == 0) begin
        #CLK_PERIOD;
    end
    rd = 0;
    $readmemh("low_freq.csv", x_1);
    $readmemh("high_freq.csv", x_2);
    $readmemh("tapshex.csv", h); 
    $readmemh("attenuations.csv", atten);
    #(CLK_PERIOD*10);
    
    // writing taps
    for(i=0; i<NUM_TAPS*NUM_FILTERS; i=i+1) begin
        wr = 1;
        wrAddr = i*4;
        wrData = h[i/NUM_TAPS][i%NUM_TAPS];
        #CLK_PERIOD
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        #CLK_PERIOD;
    end
    #(CLK_PERIOD*2);
    $display("finished writing taps");
    
    for(i=0; i<NUM_FILTERS; i=i+1)begin
        wr = 1;
        wrAddr = 4*(NUM_TAPS*NUM_FILTERS+i);
        wrData = 16'h4000;
        #CLK_PERIOD;
        wr = 0;
        wrAddr = 0;
        wrData = 0;
        #CLK_PERIOD;
    end
    #(CLK_PERIOD*2)
    
    wr = 1;
    wrAddr = 4*(NUM_TAPS*NUM_FILTERS+NUM_FILTERS);
    #CLK_PERIOD
    wr=0;
    wrAddr = 0;
    #(CLK_PERIOD*10);
    
    $display("enabled");
    
    // writing samples
    for(i=0; i<2*NUM_SAMPLES; i=i+1) begin
        if(channel) begin
            calc = 1;
            data = x_2[i/2];
        end
        else begin
            calc = 1;
            data = x_1[i/2];
        end
        #CLK_PERIOD;
        calc = 0;
        while(calcDone==0) begin
            #CLK_PERIOD;
        end
        #CLK_PERIOD;
        if(channel) begin
            $display("\t %d", outputData);
        end else begin
            $write("%d\t %d", i/2, outputData);
        end
        channel = ~channel;
        #CLK_PERIOD;
    end
    
    $stop;
end

endmodule
