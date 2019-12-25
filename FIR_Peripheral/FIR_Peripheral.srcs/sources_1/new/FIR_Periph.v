`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2019 02:17:17 PM
// Design Name: 
// Module Name: FIR_Periph
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


module FIR_Periph #
(parameter C_S_AXI_ADDR_WIDTH = 14, C_S_AXI_DATA_WIDTH = 32, DATA_WIDTH =16, NUM_FILTERS=13, NUM_TAPS=279) (
    // clock
    input clk,
    
    // Signals for ADC/DAC manager
    input calc,
    output reg calcDone,
    input channel,
    input [DATA_WIDTH-1:0] rawData,
    output reg [DATA_WIDTH-1:0] filterData,
    output reg enabled,
    
    // Microblaze signals
    input                               rd,
    input      [C_S_AXI_ADDR_WIDTH-1:0] rdAddr,
    output reg [C_S_AXI_DATA_WIDTH-1:0] rdData,
    input                               wr,
    input      [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
    input      [C_S_AXI_DATA_WIDTH-1:0] wrData,
    
    // reset signal
    input reset_l
);
parameter ADDR_WIDTH = C_S_AXI_ADDR_WIDTH-$clog2(C_S_AXI_DATA_WIDTH/8); // width of word-aligned addresses
parameter BYTE_BITS = $clog2(C_S_AXI_DATA_WIDTH/8);
parameter TAP_ADDR_WIDTH = $clog2(NUM_TAPS);

// FSM States/ variables
parameter RESET = 0, IDLE = 1, CALC = 2 ;
reg [3:0] nextState, currentState;

// signal addresses
reg [TAP_ADDR_WIDTH-1:0] hAddr, xAddr;
reg [DATA_WIDTH-1:0] hData, xData;
reg wrX[0:1];

// Circular buffer
reg [TAP_ADDR_WIDTH-1:0] currentIndex[0:1], currentIndex_D [0:1];

// signals for FIR calculation
reg [TAP_ADDR_WIDTH-1:0]        xIndex, xIndex_D, hIndex, hIndex_D;
wire signed [DATA_WIDTH-1:0] x[1:0];
reg signed [DATA_WIDTH-1:0] MAC[0:NUM_FILTERS-1], MAC_D [0:NUM_FILTERS-1];
reg signed [2*DATA_WIDTH-1:0] MAC_D_temp [0:NUM_FILTERS-1], temp_output[0:NUM_FILTERS-1];
reg [DATA_WIDTH-1:0] y_D;

// Flops to store attenuation values
reg signed [DATA_WIDTH-1:0] atten[0:NUM_FILTERS-1], atten_D [0:NUM_FILTERS-1];

// flop to keep track of channel
reg channel_D, channel_Q;

// status register bits assigned as follows
// bit 0: reset ready
// bit 1: enabled
reg [C_S_AXI_DATA_WIDTH-1:0] status, status_D;

// RAM block for circular buffer channel 0
ram #(.ADDR_WIDTH(TAP_ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) ram_x0 (
    .clk(clk),
    .addr(xAddr),
    .write_enable(wrX[0]),
    .data_in(xData),
    .data_out(x[0])
);

// RAM block for circular buffer channel 1
ram #(.ADDR_WIDTH(TAP_ADDR_WIDTH),.DATA_WIDTH(DATA_WIDTH)) ram_x1 (
    .clk(clk),
    .addr(xAddr),
    .write_enable(wrX[1]),
    .data_in(xData),
    .data_out(x[1])
);

// generating all RAM blocks for the taps for all N filters
reg wrH [0:NUM_FILTERS-1];
wire signed [DATA_WIDTH-1:0] h  [0:NUM_FILTERS-1];
genvar j;
generate
    for(j=0; j<NUM_FILTERS; j=j+1) begin
        ram #(TAP_ADDR_WIDTH, DATA_WIDTH) ram_h
        (
            .clk(clk),
            .addr(hAddr),
            .write_enable(wrH[j]),
            .data_in(hData),
            .data_out(h[j])
        );
    end
endgenerate

integer i;
// Combinational block
always @ * begin
    enabled = status[1];
    // logic for writing to attenuations
    for(i=0; i<NUM_FILTERS; i=i+1) begin
        atten_D[i] = atten[i];
    end
    if ( wr & wrAddr[C_S_AXI_ADDR_WIDTH-1:BYTE_BITS]>=(NUM_FILTERS*NUM_TAPS) ) begin
        atten_D[wrAddr[C_S_AXI_ADDR_WIDTH-1:BYTE_BITS]-(NUM_FILTERS*NUM_TAPS)] = wrData;
    end

    // logic for reading status
    rdData = 0;
    if(rd) begin
        rdData = status;
    end
    
    status_D = status;
    // State transition logic
    nextState = currentState;
    wrX[0] = 0;
    wrX[1] = 0;
    y_D = filterData;
    xIndex_D = xIndex;
    hIndex_D = hIndex;
    xAddr = 0;
    hAddr = 0;
    xData = 0;
    hData = 0;
    currentIndex_D[0] = currentIndex[0];
    currentIndex_D[1] = currentIndex[1];
    calcDone = 0;
    channel_D = channel_Q;
    
    for(i=0; i<NUM_FILTERS; i=i+1) begin
        wrH[i] = 0;
        MAC_D_temp[i] = 0;
        MAC_D[i] = MAC[i];
        temp_output[i] = 0;
    end
        
    case (currentState)
        IDLE: begin
            for(i=0; i<NUM_FILTERS; i=i+1) begin
                MAC_D[i] = 0;
            end
            // writing samples
            if ( calc & enabled ) begin
                nextState = CALC;
                channel_D = channel;
                wrX[channel_D] = 1;
                xAddr = currentIndex[channel_D];
                xData = rawData;
                xIndex_D = currentIndex[channel_D];
                hIndex_D = 0;
            end
            // writing taps
            else if ( wr & wrAddr[C_S_AXI_ADDR_WIDTH-1:BYTE_BITS]<(NUM_FILTERS*NUM_TAPS)) begin
                // decoding the address
                for(i=0; i<NUM_FILTERS; i=i+1) begin
                    // checking if the address is within bounds for a given filter block
                    if(wrAddr[C_S_AXI_ADDR_WIDTH-1:BYTE_BITS]>=i*NUM_TAPS && wrAddr[C_S_AXI_ADDR_WIDTH-1:BYTE_BITS]<(i+1)*NUM_TAPS) begin
                        wrH[i] = 1;
                        hAddr = wrAddr[ADDR_WIDTH+1:BYTE_BITS]-i*NUM_TAPS;
                        hData = wrData[DATA_WIDTH-1:0];
                    end
                end
            end
            
            // turning the enable bit on
            if(wr & wrAddr[C_S_AXI_ADDR_WIDTH-1:BYTE_BITS]==(NUM_FILTERS*NUM_TAPS)+NUM_FILTERS) begin //TODO change to a different value
                status_D[1] = 1;
            end
           
        end
        CALC: begin
            // Asserting addresses so RAM gives x,h
            hAddr = hIndex;
            xAddr = xIndex;
            
            // Multiply and Accumulate for all filters
            for(i=0; i<NUM_FILTERS; i=i+1) begin
                MAC_D_temp[i] = (x[channel_Q]*h[i] + 32'sh4000);
//                MAC_D_temp[i] = (x[channel]*h[i]);
                MAC_D[i] = MAC[i] + MAC_D_temp[i][2*DATA_WIDTH-2:DATA_WIDTH-1];
            end
            
            // Decrementing xIndex
            xIndex_D = xIndex - 1'b1;
            if(xIndex == 0) begin
                xIndex_D = NUM_TAPS - 1;
            end
            
            // Incrementing hIndex
            hIndex_D = hIndex + 1'b1;
            
            // checking if done
            if (hIndex == NUM_TAPS - 1) begin
                nextState = IDLE;
                // outputting value
                y_D = 0;
                for(i=0; i<NUM_FILTERS; i=i+1) begin
                    temp_output[i] = atten[i]*MAC_D[i] + 32'sh2000;
                    y_D = y_D + temp_output[i][2*DATA_WIDTH-3:DATA_WIDTH-2];
                end
                calcDone = 1;
                // Incrementing currentIndex
                currentIndex_D[channel_Q] = currentIndex[channel_Q] + 1'b1;
                if(currentIndex[channel_Q] == NUM_TAPS - 1) begin
                    currentIndex_D[channel_Q] = 0;
                end
            end
        end
        
        RESET: begin
            // RESET clears all the values in the circular buffer
            xAddr = xIndex;
            wrX[0] = 1;
            wrX[1] = 1;
            xData = 0;
            
            xIndex_D = xIndex+1'b1;
            
            if(xIndex == NUM_TAPS - 1) begin
                status_D[0]=1;
                nextState = IDLE;
            end
        end
        default: begin
            nextState = IDLE;
        end
    endcase
end

// Sequential block
always @(posedge clk) begin
    if(!reset_l) begin
        currentIndex[0] <= 0;
        currentIndex[1] <= 0;
        currentState <= RESET;
        filterData <= 0;
        xIndex <= 0;
        hIndex <= 0;
        for(i=0; i<NUM_FILTERS;i=i+1) begin
            atten[i] <= 0;
            MAC[i] <= 0;
        end
        channel_Q <= 0;
        status <= 0;
    end
    else begin
        currentState <= nextState;
        currentIndex[0] <= currentIndex_D[0];
        currentIndex[1] <= currentIndex_D[1];
        xIndex <= xIndex_D;
        hIndex <= hIndex_D;
        for(i=0; i<NUM_FILTERS; i=i+1) begin
            MAC[i] <= MAC_D[i];
            atten[i] <= atten_D[i];
        end
        
        filterData <= y_D;
        channel_Q <= channel_D;
        status <= status_D;
    end
end
endmodule
