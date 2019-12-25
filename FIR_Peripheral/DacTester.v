`resetall
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ross Williamson (BSCoE 2009)
// 
// Create Date:    18:36:57 11/24/2008 
// Design Name: 
// Module Name:    DacTester 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// SPIPeripheral.v
// SPI Peripheral model - non-synthesizable

module DacTester(input SCK, input SDI, input CS_, output reg SDO);
integer i, j;

reg [7:0] ControlReg;
reg [15:0] DataReg;
reg [15:0] ChanAData, ChanBData;
initial
begin
  SDO = 0 ;
  ControlReg = 0 ;
  ChanAData = 0 ;
  ChanBData = 0;
end

always @ (negedge CS_)
begin
	   for (i = 23;i >= -1; i = i-1) begin
			if (i >= 16) begin
			  while (SCK == 0)
			  begin
				 #1 ;
			  end
			  ControlReg[i - 16] = SDI ;
			  while (SCK == 1)
			  begin
				 #1 ;
			  end
			end
			
			else if (i < 16 && i >= 0) begin
			  while (SCK == 0)
			  begin
				 #1 ;
			  end
			  DataReg[i] = SDI ;
			  while (SCK == 1)
			  begin
				 #1 ;
			  end		
			end

			else if (i == -1) begin
				if (ControlReg[3:0] == 0) begin
					ChanAData = DataReg;
                    $display("Channel A: %h",{~ChanAData[15],ChanAData[14:0]}) ;
//                    $display("Channel A: %h",ChanAData) ;
				end else if (ControlReg[3:0] == 1) begin
					ChanBData = DataReg;
                    $display("Channel B: %h",{~ChanBData[15],ChanBData[14:0]}) ;
//                    $display("Channel B: %h",ChanBData) ;
				end
			end
		end
end

endmodule

