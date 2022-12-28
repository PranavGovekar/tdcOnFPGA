`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2022 04:40:58 PM
// Design Name: 
// Module Name: Coarse_Counter_22
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


module Coarse_counter(
    input clk,
    input start,
    input stop,
    input reset,
    output reg [15:0] data
    );

    reg [15:0] counter_1;    
    reg [15:0] start_1;
    reg [15:0] stop_1;

    reg set;
    
    wire i_start;
    wire i_stop;
    
    wire i_reset;
    assign i_reset = reset | set;
//    assign data = thanos;

    EdgeDetector Start (
        .clk(clk),
        .reset(reset),
        .level(start),
        .out(i_start)
    );
    
    EdgeDetector Stop (
        .clk(clk),
        .reset(reset),
        .level(stop),
        .out(i_stop)
    );
    
    always @(negedge clk) begin
        if(i_reset) begin
            counter_1 <= 0;
        end
        else if(counter_1 >= 60000) begin
            counter_1 <= 0;
        end
        else begin
            counter_1 = counter_1 + 1;
        end
    end
    
    always @(posedge clk) begin
        if(i_start) begin
            start_1 <= counter_1;
        end
    end
    
    always @(posedge clk) begin
        if(i_stop) begin
            stop_1 <= counter_1;
        end
    end
   
    //STATE MACHINE
   localparam [2:0]
        WAIT_FS =       3'b000,
        WAIT_FT =       3'b001,
        COUNTER =       3'b010,
        RESET =         3'b011
        ;   
        
    reg [2:0] state, next;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= WAIT_FS;
        end
        else begin
            state <= next;
        end
    end 

    
    always @(posedge clk) begin
        case(state) 
            WAIT_FS : begin
                set = 1'b0;
                if(start) begin
                    next = WAIT_FT;
                end
                else begin
                    next = WAIT_FS;
                end
            end
            
            WAIT_FT : begin
                if(stop == 1'b1) begin
                    next = COUNTER;
                end
                else begin
                    next = WAIT_FT;
                end
            end
            
            COUNTER : begin
                if(start_1 > stop_1) begin
                    data = (60000 - start_1) + stop_1 + 1;
                end
                else begin
                    data = stop_1 - start_1;
                end
                next = RESET;
            end
                 
            RESET : begin
                if(start == 1'b0 && stop == 1'b0) begin
                    set = 1'b1;
                    next = WAIT_FS;
                end
                else begin
                    next = RESET;
                end
            end
        endcase
    end      
  
endmodule