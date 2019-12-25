`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2019 02:29:33 PM
// Design Name: 
// Module Name: ram
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


module ram # 
    (parameter ADDR_WIDTH = 4, DATA_WIDTH = 32)
    (
        input                       clk,
        input                       write_enable,
        input   [ADDR_WIDTH-1:0]    addr,
        input   [DATA_WIDTH-1:0]    data_in,
        output  [DATA_WIDTH-1:0]    data_out
    );
    
    parameter numRegisters = 1 << (ADDR_WIDTH) ;
    reg [DATA_WIDTH-1:0] ram [numRegisters-1:0] ;
    integer i;
    
    always @(posedge clk) begin
        if (write_enable)
            ram[addr] <= data_in ;
    end
    
    assign data_out = ram[addr] ;
endmodule
