`timescale 1ns / 1ps

module Axi4Lite_SPI # 
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32, SPI_COUNTER_WIDTH = 10)
    (
    // SPI
    output reg  SCK,
    output reg  SDI,
    input       SDO,
    output reg  CS,
    // AXI
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
    input       S_AXI_RREADY
    );
    
wire [C_S_AXI_ADDR_WIDTH-1:0] wrAddr;
wire [C_S_AXI_DATA_WIDTH-1:0] wrData;
wire wr;
wire [C_S_AXI_ADDR_WIDTH-1:0] rdAddr;
wire rd;
reg [C_S_AXI_DATA_WIDTH-1:0] rdData ;
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

// FSM stuff
parameter IDLE = 0, DATA1 = 1, DATA2 = 2, DATA3 = 3, DATA4 = 4, DATA5 = 5, DATA6 = 6, DATA7 = 7;
//reg hold_flag, hold_flag_D;
reg[2:0] currentState, nextState;
reg[SPI_COUNTER_WIDTH-1:0] counter_D, counter, spi_wait_cycles, spi_wait_cycles_D, wait_counter, wait_counter_D; 
reg[4:0] spi_data_width, spi_data_width_D;

// Memory
reg[C_S_AXI_DATA_WIDTH-1:0] data_in, data_in_D, temp_data_out, temp_data_out_D, data_out, data_out_D;

// Combinational Block
always @ * begin
    // AXI stuff
    data_out_D = data_out;
    temp_data_out_D = temp_data_out;
    data_in_D = data_in;
    spi_wait_cycles_D = spi_wait_cycles;
    rdData = data_out;
    wait_counter_D = wait_counter;
    spi_data_width_D = spi_data_width;
 //   hold_flag_D = hold_flag;
    
//    if(rd) begin
////        hold_flag_D = hold_flag_D + 1;
// //       if(hold_flag == 1) begin
//            data_out_D[SPI_DATA_WIDTH] = 0;
////        end
//    end
    
    if(wr) begin
        if(wrAddr == 0) begin
            data_in_D = wrData;
        end else if (wrAddr == 4) begin
            spi_wait_cycles_D = wrData[SPI_COUNTER_WIDTH-1:0];
        end else if (wrAddr == 8) begin
            data_out_D[spi_data_width] = 0;
        end else begin
            spi_data_width_D = wrData[4:0];
        end
    end

    // More FSM stuff
    nextState = currentState;
    counter_D = counter;
    CS = 1;
    SDI = 0;
    SCK = 0;
    
    if(spi_wait_cycles != 0) begin
        wait_counter_D = wait_counter + 1;
    end
    
    case(currentState)
        IDLE: begin
            if(spi_wait_cycles != 0) begin
                if(wait_counter == spi_wait_cycles-1) begin
                    wait_counter_D = 0;
                    nextState = DATA1;
                    counter_D = 2;
                    CS = 0;
                end
                else begin
                    CS = 1;
                end
            end else begin
                CS = 1;
            end
        end
        
        DATA1: begin
            CS = 0;
            counter_D = counter - 1;
            
            if(counter <= 2) begin
                SDI = data_in[spi_data_width-1];
            end
            
            if(counter == 0) begin
                SCK = 1;
                counter_D = spi_data_width-1;
                nextState = DATA2;
            end
        end
        
        DATA2: begin
            CS = 0;
            nextState = DATA3;
            SDI = data_in[counter];
            SCK = 1;
        end
        
        DATA3: begin
            temp_data_out_D[counter] = SDO;
            SDI = data_in[counter];
//            if(counter == 0) begin
//                CS = 1;
//                nextState = IDLE;
//                SCK = 0;
//                data_out_D[SPI_DATA_WIDTH-1:0] = temp_data_out;
//                data_out_D[SPI_DATA_WIDTH] = 1;
//            end else begin
                CS = 0;
                SCK = 1;
                nextState = DATA4;
//            end
        end
        
        DATA4: begin
            SCK = 0;
            if(counter == 0) begin
                CS = 1;
                nextState = IDLE;
                data_out_D = temp_data_out;
                data_out_D[spi_data_width] = 1;
            end else begin
                CS = 0;
                nextState = DATA5;
                SDI = data_in[counter];
                counter_D = counter - 1;
            end
        end
        
        DATA5: begin
            CS = 0;
            nextState = DATA6;
            SDI = data_in[counter];
            SCK = 0;
        end
        
        DATA6: begin
            CS = 0;
            nextState = DATA7;
            SDI = data_in[counter];
            SCK = 0;
        end
        
        DATA7: begin
            SDI = data_in[counter];
//            if(counter == 0) begin
//                CS = 1;
//                nextState = IDLE;
//                SCK = 0;
//                data_out_D[SPI_DATA_WIDTH-1:0] = temp_data_out;
//                data_out_D[SPI_DATA_WIDTH] = 1;
//            end else begin
                CS = 0;
                nextState = DATA2;
                SCK = 1;
//            end
        end
        
        default: begin
            nextState = IDLE;
        end
    endcase
end

// Sequential Block
always @(posedge S_AXI_ACLK) begin
    if(!S_AXI_ARESETN) begin
        currentState <= IDLE;
        counter <= 0;
        temp_data_out <= 0;
        data_out <= 0;
        data_in <= 0;
        spi_wait_cycles <= 0;
        wait_counter <= 0;
        spi_data_width <= 0;
//        hold_flag <= 0;
    end
    else begin
        currentState <= nextState;
        counter <= counter_D;
        temp_data_out <= temp_data_out_D;
        data_out <= data_out_D;
        data_in <= data_in_D;
        spi_wait_cycles <= spi_wait_cycles_D;
        wait_counter <= wait_counter_D;
        spi_data_width <= spi_data_width_D;
//        hold_flag <= hold_flag_D;
    end
end
endmodule
