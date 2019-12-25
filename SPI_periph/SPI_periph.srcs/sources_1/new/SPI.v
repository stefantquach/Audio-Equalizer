`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2019 03:17:51 PM
// Design Name: 
// Module Name: SPI
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


module SPI # (parameter DATA_WIDTH=16, CLK_CYCLES = 3)(
    // SPI
    
    // Bus
    input                       wr,
    input  [DATA_WIDTH-1:0]      wrData,
    input                       rd,
    output reg [DATA_WIDTH:0]    rdData
    );


endmodule
