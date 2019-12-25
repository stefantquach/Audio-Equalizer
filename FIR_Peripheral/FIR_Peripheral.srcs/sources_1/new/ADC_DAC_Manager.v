`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2019 04:04:25 PM
// Design Name: 
// Module Name: ADC_DAC_Manager
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


module ADC_DAC_Controller
#(parameter C_S_AXI_ADDR_WIDTH = 11, C_S_AXI_DATA_WIDTH = 32, DATA_WIDTH =16)(
    // clock
    input clk,
    input reset_L,
    // signals for FIR peripheral
    output  reg   calc,
    input calcDone,
    output  reg   channel,
    output  reg   [DATA_WIDTH-1:0] rawData,
    input [DATA_WIDTH-1:0] filterData,
    input enabled,
    
    // Axi4Lite Bus to ADC
    output          [C_S_AXI_ADDR_WIDTH-1:0] ADC_AXI_AWADDR,
    output          ADC_AXI_AWVALID,
    input           ADC_AXI_AWREADY,
    output          [C_S_AXI_DATA_WIDTH-1:0] ADC_AXI_WDATA,
    output          [3:0] ADC_AXI_WSTRB,
    output          ADC_AXI_WVALID,
    input           ADC_AXI_WREADY,
    input           [1:0] ADC_AXI_BRESP,
    input           ADC_AXI_BVALID,
    output          ADC_AXI_BREADY,
    output          [C_S_AXI_ADDR_WIDTH-1:0] ADC_AXI_ARADDR,
    output          ADC_AXI_ARVALID,
    input           ADC_AXI_ARREADY,
    input           [C_S_AXI_DATA_WIDTH-1:0] ADC_AXI_RDATA,
    input           [1:0] ADC_AXI_RRESP,
    input           ADC_AXI_RVALID,
    output          ADC_AXI_RREADY,
    
    // Axi4Lite Bus to DAC
    output          [C_S_AXI_ADDR_WIDTH-1:0] DAC_AXI_AWADDR,
    output          DAC_AXI_AWVALID,
    input           DAC_AXI_AWREADY,
    output          [C_S_AXI_DATA_WIDTH-1:0] DAC_AXI_WDATA,
    output          [3:0] DAC_AXI_WSTRB,
    output          DAC_AXI_WVALID,
    input           DAC_AXI_WREADY,
    input           [1:0] DAC_AXI_BRESP,
    input           DAC_AXI_BVALID,
    output          DAC_AXI_BREADY,
    output          [C_S_AXI_ADDR_WIDTH-1:0] DAC_AXI_ARADDR,
    output          DAC_AXI_ARVALID,
    input           DAC_AXI_ARREADY,
    input           [C_S_AXI_DATA_WIDTH-1:0] DAC_AXI_RDATA,
    input           [1:0] DAC_AXI_RRESP,
    input           DAC_AXI_RVALID,
    output          DAC_AXI_RREADY
);

// ADC signals
reg ADC_rd, ADC_wr;
wire ADC_rdDone, ADC_wrDone;
reg [C_S_AXI_ADDR_WIDTH-1:0] ADC_rdAddr, ADC_wrAddr;
reg [C_S_AXI_DATA_WIDTH-1:0]  ADC_wrData;
wire [C_S_AXI_DATA_WIDTH-1:0] ADC_rdData;

// DAC signals
reg DAC_rd, DAC_wr;
wire DAC_rdDone, DAC_wrDone;
reg [C_S_AXI_ADDR_WIDTH-1:0] DAC_rdAddr, DAC_wrAddr;
reg [C_S_AXI_DATA_WIDTH-1:0] DAC_wrData;
wire [C_S_AXI_DATA_WIDTH-1:0] DAC_rdData;

// Instantiation of ADC manager
Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) ADC_manager (
    // Simple Bus
    .wrAddr(ADC_wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
    .wrData(ADC_wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
    .wr(ADC_wr),                            // input    
    .wrDone(ADC_wrDone),                    // output
    .rdAddr(ADC_rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
    .rdData(ADC_rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
    .rd(ADC_rd),                            // input
    .rdDone(ADC_rdDone),                    // output
    // Axi4Lite Bus
    .M_AXI_ACLK(clk),
    .M_AXI_ARESETN(reset_L),      // input
    .M_AXI_AWADDR(ADC_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
    .M_AXI_AWVALID(ADC_AXI_AWVALID),      // output
    .M_AXI_AWREADY(ADC_AXI_AWREADY),      // input
    .M_AXI_WDATA(ADC_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
    .M_AXI_WSTRB(ADC_AXI_WSTRB),          // output   [3:0]
    .M_AXI_WVALID(ADC_AXI_WVALID),        // output
    .M_AXI_WREADY(ADC_AXI_WREADY),        // input
    .M_AXI_BRESP(ADC_AXI_BRESP),          // input    [1:0]
    .M_AXI_BVALID(ADC_AXI_BVALID),        // input
    .M_AXI_BREADY(ADC_AXI_BREADY),        // output
    .M_AXI_ARADDR(ADC_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
    .M_AXI_ARVALID(ADC_AXI_ARVALID),      // output
    .M_AXI_ARREADY(ADC_AXI_ARREADY),      // input
    .M_AXI_RDATA(ADC_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
    .M_AXI_RRESP(ADC_AXI_RRESP),          // input    [1:0]
    .M_AXI_RVALID(ADC_AXI_RVALID),        // input
    .M_AXI_RREADY(ADC_AXI_RREADY)         // output
);

// Instantiation of DAC manager
Axi4LiteManager #(.C_M_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .C_M_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) DAC_manager (
    // Simple Bus
    .wrAddr(DAC_wrAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
    .wrData(DAC_wrData),                    // input    [C_M_AXI_DATA_WIDTH-1:0]
    .wr(DAC_wr),                            // input    
    .wrDone(DAC_wrDone),                    // output
    .rdAddr(DAC_rdAddr),                    // input    [C_M_AXI_ADDR_WIDTH-1:0]
    .rdData(DAC_rdData),                    // output   [C_M_AXI_DATA_WIDTH-1:0]
    .rd(DAC_rd),                            // input
    .rdDone(DAC_rdDone),                    // output
    // Axi4Lite Bus
    .M_AXI_ACLK(clk),
    .M_AXI_ARESETN(reset_L),              // input
    .M_AXI_AWADDR(DAC_AXI_AWADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0] 
    .M_AXI_AWVALID(DAC_AXI_AWVALID),      // output
    .M_AXI_AWREADY(DAC_AXI_AWREADY),      // input
    .M_AXI_WDATA(DAC_AXI_WDATA),          // output   [C_M_AXI_DATA_WIDTH-1:0]
    .M_AXI_WSTRB(DAC_AXI_WSTRB),          // output   [3:0]
    .M_AXI_WVALID(DAC_AXI_WVALID),        // output
    .M_AXI_WREADY(DAC_AXI_WREADY),        // input
    .M_AXI_BRESP(DAC_AXI_BRESP),          // input    [1:0]
    .M_AXI_BVALID(DAC_AXI_BVALID),        // input
    .M_AXI_BREADY(DAC_AXI_BREADY),        // output
    .M_AXI_ARADDR(DAC_AXI_ARADDR),        // output   [C_M_AXI_ADDR_WIDTH-1:0]
    .M_AXI_ARVALID(DAC_AXI_ARVALID),      // output
    .M_AXI_ARREADY(DAC_AXI_ARREADY),      // input
    .M_AXI_RDATA(DAC_AXI_RDATA),          // input    [C_M_AXI_DATA_WIDTH-1:0]
    .M_AXI_RRESP(DAC_AXI_RRESP),          // input    [1:0]
    .M_AXI_RVALID(DAC_AXI_RVALID),        // input
    .M_AXI_RREADY(DAC_AXI_RREADY)         // output
);

parameter INIT0=0, INIT1=1, INIT2=2, INIT3=3, INIT4=4, READ_ADC=5, WRITE_DAC=6, WAIT1=7, WAIT2=8;
reg[7:0] currentState, nextState;
reg channel_D;

// Combinational block
always @ * begin
    ADC_rdAddr = 0;
    DAC_rd = 0;
    DAC_rdAddr = 0;
    
    // State transition logic
    nextState = currentState;
    calc = 0;
    ADC_wr = 0;
    ADC_wrAddr = 0;
    ADC_wrData = 0;
    ADC_rd = 0;
    DAC_wr = 0;
    DAC_wrAddr = 0;
    DAC_wrData = 0;
    channel_D = channel;
    rawData = 0;
    
    
    case(currentState)
        INIT0: begin
            ADC_wr = 1;
            ADC_wrAddr = 12; // address to write data width
            ADC_wrData = 16;
            DAC_wr = 1;
            DAC_wrAddr = 12;
            DAC_wrData = 24;
            if(ADC_wrDone & DAC_wrDone) begin
                nextState = INIT1;
            end 
        end
        
        INIT1: begin
            if(enabled) begin
                ADC_wr = 1;
                ADC_wrAddr = 4; 
                ADC_wrData = 300;
                DAC_wr = 1;
                DAC_wrAddr = 4;
                DAC_wrData = 300;
                if(ADC_wrDone & DAC_wrDone) begin
                    nextState = INIT2;
                end 
            end
        end
        
        INIT2: begin
            ADC_wr = 1;
            ADC_wrAddr = 0; 
            ADC_wrData[13:0] = 0;
            ADC_wrData[14] = channel;
            ADC_wrData[15] = 1;
            if(ADC_wrDone) begin
                nextState = INIT3;
            end 
        end
        
        INIT3: begin
            // waiting for first sample from ADC
            ADC_rd = 1;
            if(ADC_rdData[DATA_WIDTH]) begin
                nextState = INIT4;
            end
        end
        
        INIT4: begin
            // resetting the ready bit
            ADC_wr = 1;
            ADC_wrAddr = 8;
            nextState = READ_ADC;
        end
        
        READ_ADC: begin
            ADC_rd = 1;
            if(ADC_rdData[DATA_WIDTH]) begin
                calc = 1;
                rawData = {~ADC_rdData[DATA_WIDTH-1], ADC_rdData[DATA_WIDTH-2:0]};
                nextState = WAIT1;
            end
        end
        
        WAIT1: begin
            // resetting the ready bit
            ADC_wr = 1;
            ADC_wrAddr = 8;
            nextState = WAIT2;
        end
        
        WAIT2: begin
            // Waiting for FIR calculation to finish
            if(calcDone) begin
                nextState = WRITE_DAC;
                DAC_wr = 1;
                DAC_wrAddr = 0;
                DAC_wrData[15:0] = {~filterData[15], filterData[14:0]};
                DAC_wrData[23:20] = 4'h3;
                DAC_wrData[19:17] = 0;
                DAC_wrData[16] = channel;
            end
        end
        
        WRITE_DAC: begin
            nextState = READ_ADC;
            channel_D = ~channel;
            // writing the control bits
            ADC_wr = 1;
            ADC_wrAddr = 0;
            ADC_wrData[13:0] = 0;
            ADC_wrData[14] = ~channel;
            ADC_wrData[15] = 1;
        end
        
        default:begin
            nextState = INIT0;
        end
    endcase
end

// Sequential block
always @(posedge clk) begin
    if(!reset_L) begin
        channel <= 0;
        currentState <= INIT0;
    end
    else begin
        channel <= channel_D;
        currentState <= nextState;
    end
end

endmodule
