`resetall
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Ross Williamson (BSCoE 2009)
// 
// Create Date:    18:36:57 11/24/2008 
// Design Name: 
// Module Name:    adc_tester 
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

module AdcTester(input SCK, input SDI, input CS_, output reg SDO);
parameter TestSineWaveFileL = "low_freq.csv";
parameter TestSineWaveFileR = "low_freq.csv";
parameter INPUT_LEN = 1000 ; 

reg [15:0] TestSineWaveChannelL[0:INPUT_LEN-1] ;
reg [15:0] TestSineWaveChannelR[0:INPUT_LEN-1] ;

integer i, j, ChanSelect ;

reg [15:0] SDIReg, SDOReg ;
reg random_boi;
initial
begin
  // I assume the input hex values
  // are in 1.15.  So, before outputting them from the ADC, I convert them
  // to an unsigned value between 0 and 65535 to properly mimic the activity
  // of the actual ADC.
  $readmemh(TestSineWaveFileL,TestSineWaveChannelL);
  $readmemh(TestSineWaveFileR,TestSineWaveChannelR);
  SDO = 0 ;
  SDOReg = 0 ;
  SDIReg = 0 ;
end

always @ (negedge CS_)
begin
    // Read out the first SDO - throw out first sample
    for (j = 15;j >= 0; j = j-1) begin
        SDO = SDOReg[j] ;
        while (SCK == 0) begin
            #1 ;
        end
        SDIReg[j] = SDI ;
        while (SCK == 1) begin
            #1 ;
        end
    end
    // Read out the 2 sine waves
    for (i = 0; i < INPUT_LEN; i = i+1) begin
        for (ChanSelect = 0; ChanSelect < 2; ChanSelect = ChanSelect + 1) begin
           // Flip the high order bit on the input to add 32768.
            if (SDIReg[15:14] == 2'b10) begin
                SDOReg = {~(TestSineWaveChannelL[i][15]), TestSineWaveChannelL[i][14:0]};
//                SDOReg = TestSineWaveChannelL[i];
            end else if (SDIReg[15:14] == 2'b11) begin
                SDOReg = {~(TestSineWaveChannelR[i][15]), TestSineWaveChannelR[i][14:0]};
//                SDOReg = TestSineWaveChannelR[i];
            end
        
            for (j = 15;j >= 0; j = j-1) begin
                SDO = SDOReg[j] ;
                while (SCK == 0) begin
                    #1 ;
                end
                SDIReg[j] = SDI ;
                while (SCK == 1) begin
                    #1 ;
                end
            end
        end
    end
end
endmodule
