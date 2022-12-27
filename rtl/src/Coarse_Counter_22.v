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


module Coarse_Counter_22(
    input clk,
    input start,
    input stop,
    input reset,
    output reg[15:0] data
    );
    
    reg start_hold;
    reg [15:0] counter;
    reg set;
    reg [1:0] start_flag;
    reg [15:0] thanos;
    
//    initial begin
//        start_flag = 0;
//        state = WAIT_FS;
//        counter = 0;
//    end
    
    always @(posedge clk) begin
        if(start_hold == 1'b1) begin
            if(stop == 1'b1) begin
                thanos <= counter + 1;
            end
            else begin
                counter = counter + 1;
            end
        end
        if(set == 1'b1) begin
            counter = 0;
        end
    end
    
    always @(posedge clk) begin
        if(start == 1'b1 && start_flag == 1'b0) begin
            set = 0;
            start_hold = 1;
            start_flag = 1;
        end
        
        if(stop == 1'b1 && start_flag == 1'b1) begin
            start_flag = 2;
        end
        
        if(start == 1'b0 && stop == 1'b0 && start_flag == 2) begin
            start_hold = 0;
            start_flag = 0;
            set = 1;
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
                if(start == 1'b1 && stop == 1'b1) begin
                    data = 0;
                    next = RESET;
                end
                else if (start == 1'b1) begin
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
                data <= thanos;
                next <= RESET;
            end
                   
            RESET : begin
                if(start == 1'b0 && stop == 1'b0) begin
                    next = WAIT_FS;
                end
                else begin
                    next = RESET;
                end
            end
        endcase
    end      
  
endmodule
