`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2019 01:55:52 PM
// Design Name: 
// Module Name: Axi4LiteSPI
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
///////////////////////////////////////////////////////////////////////////////


module Axi4LiteSPI#
    (parameter C_R_ADDR_WIDTH = 6, C_R_DATA_WIDTH = 32, C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32, IDLE=0, INIT=1, SHIGH=2, SLOW=3, OFF=4)
    (
        // Axi4Lite Bus
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
        
        output		reg sck,
        output      reg conv,
        output		reg sdi,
        input       sdo
        
    );
    
    wire [C_R_DATA_WIDTH-1:0] wrData;
    wire [C_R_ADDR_WIDTH-1:0] wrAddr;
    reg [C_R_DATA_WIDTH-1:0] rdData;
    wire [C_R_ADDR_WIDTH-1:0] rdAddr;
    
    reg [C_R_DATA_WIDTH-1:0] reg0D, reg0Q;
    reg [C_R_DATA_WIDTH-1:0] reg1D, reg1Q;
    reg [3:0] sclkCountD, sclkCountQ;
    reg [15:0] convCountD, convCountQ;
    reg [15:0] CONV_LIMIT_D, CONV_LIMIT_Q;
    reg [3:0] currentState, nextState;
    wire rd;
    wire wr;
    reg [7:0] indexD, indexQ;
    reg [7:0] writeIndexD, writeIndexQ;
    reg [7:0] DATA_WIDTH_D, DATA_WIDTH_Q;
    reg [31:0] dataOutD, dataOutQ;
    reg [31:0] dataInD, dataInQ;
  //  reg [31:0] SAMPLE_RATE;
    reg sdiD, sdiQ;
    reg convD, convQ;
    reg sckD, sckQ;
    reg[31:0] rdDataD, rdDataQ; 
    reg[15:0] resultWordD, resultWordQ; 
    
    reg doneD, doneQ;
    

    
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
    );
    
    always @* begin
    nextState = currentState;
    indexD = indexQ;
    writeIndexD = writeIndexQ;
    sclkCountD = sclkCountQ;
    sdiD = sdiQ;
    sckD = sckQ;
    convD = convQ;
    CONV_LIMIT_D = CONV_LIMIT_Q;
    DATA_WIDTH_D = DATA_WIDTH_Q;
    dataInD = dataInQ;
    dataOutD = dataOutQ;
    rdDataD = rdDataQ;
    resultWordQ = resultWordD;
    doneD = doneQ;
    
    sdi = sdiQ;
    conv = convQ;
    sck = sckQ;
    rdDataD[30:16] = 0;
    
    rdData =0;
    
    
    
    
    
    
    

    
    if (wr) begin
        if (wrAddr == 8) begin
            DATA_WIDTH_D = wrData;
        end
        if (wrAddr == 4) begin
            CONV_LIMIT_D = wrData;
            //CONV_LIMIT_D = 30000000/SAMPLE_RATE; //MOVE THIS TO THE C CODE
        end
        if (wrAddr == 0) begin
            nextState = OFF;
        end
        if(wrAddr == 12) begin
            dataOutD = wrData;
        end
        
    end
    
    
     convCountD = convCountQ+1;
     if (convCountQ >= CONV_LIMIT_Q-1) begin
                convCountD = 0;  
     end
     
     if (rd) begin      
         if(doneQ==1) begin
           doneD=0;
           rdData[15:0] = resultWordQ[15:0];
           rdData[31]=1;
        
         end
                     
    end
   
    
 
    
        case (currentState) 
        
            OFF: begin 
                if(wr) begin
                    if(wrAddr == 0) begin
                     nextState = IDLE;
                     end
                 end
             end        
        
        
            IDLE: begin
               // rdData = rdDataQ;
               
                sdiD=0;
                sckD=0;          
                convD=1;
           
//                if(wr) begin
//                    if(wrAddr == 12) begin
//                        dataOutD[31:16] = wrData[31:16];
//                        dataOutD[15]=  !wrData[15];
//                        dataOutD[14:0] = wrData[14:0];
                        
//                    end
//                end
                
//                if (rd) begin      
//                     if(doneQ==1) begin
//                       doneD=0;
//                       rdData[15:0] = dataInQ[15:0];
//                       rdData[31]=1;
                    
//                     end
                     
//                end
                
                if (convCountQ >= CONV_LIMIT_Q-1) begin
                    convCountD = 0;  
                    convD=0;
                    sckD=0;
                    sclkCountD=0;
                    nextState = INIT;   
                    dataInD=0;           
                end
            end 
            
            
            INIT: begin
                convD=0;
                sckD=0;
                sclkCountD = sclkCountQ+1;
                
//                if (rd) begin
//                    rdData=0;
//                end
                
                if (sclkCountQ == 1) begin
                    nextState = SHIGH;
                    indexD = DATA_WIDTH_Q-1;
                    sclkCountD =0;
                end
                else begin
                    sdiD = dataOutQ[writeIndexQ];
                    writeIndexD = writeIndexQ -1;
                end
            end
            
            SHIGH: begin
                convD=0;
                sckD=1;
                sclkCountD = sclkCountQ+1;
                rdDataD[31]=0;
                
//                if (rd) begin
//                    rdData=0;
//                end
               
                if (sclkCountQ == 2) begin
                   
                    sdiD = dataOutQ[writeIndexQ];
                    writeIndexD = writeIndexQ -1;
                    sclkCountD =0;
                    nextState = SLOW;
                    dataInD[indexQ] = sdo;
                  
                    
                    if (indexQ == 0) begin
                        nextState = IDLE;
                        indexD = DATA_WIDTH_Q-1;
                        writeIndexD = DATA_WIDTH_Q-1;
                        resultWordD[15:1] = dataInQ[15:1];
                        resultWordD[0] = sdo;                     
                        doneD=1;
                 
                       
                    end
                    
                    else begin
                        indexD = indexQ-1;
                    end
                end
            end
            
            SLOW: begin
                convD =0;
                sckD=0;
                sclkCountD = sclkCountQ+1;
//                if (rd) begin
//                    rdData=0;
//                end
                if (sclkCountQ == 2) begin
                    nextState = SHIGH;
                    sclkCountD =0;
                end
            end
                    
                    
                    
    
        
    endcase
    
    end
    
    always @ (posedge S_AXI_ACLK) begin
        if ( !S_AXI_ARESETN ) begin
            sclkCountQ <= 0;
            convCountQ <= 0;
          // CONV_LIMIT <=0;
           // sck <= 0;
            indexQ <=0;
            writeIndexQ <= 0;
            currentState <= OFF;
            sdiQ <=0;
            convQ<=0;
            sckQ<=0;
            CONV_LIMIT_Q <= 0;
            DATA_WIDTH_Q <= 0;
            dataOutQ <= 0;
            dataInQ <= 0;
            rdDataQ <=0;
            doneQ <= 0;    
            resultWordQ <= 0;
         
        end else begin   
            // IMPLEMENTS FLOPS
            rdDataQ <= rdDataD;
            sclkCountQ <= sclkCountD;
            convCountQ <= convCountD;
            indexQ <= indexD;
            writeIndexQ <= writeIndexD;
            currentState <= nextState;
            sdiQ <= sdiD;
            sckQ <= sckD;
            convQ <= convD;
            CONV_LIMIT_Q <= CONV_LIMIT_D;
            DATA_WIDTH_Q <= DATA_WIDTH_D;
            dataOutQ <= dataOutD;
            dataInQ <= dataInD;
            doneQ <= doneD;
            resultWordQ <= resultWordD;
            
        end
    end
    
endmodule