`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2022 11:00:54 AM
// Design Name: 
// Module Name: TDC
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


module TDC(
    input clk,
    input start,
    input stop,
    input reset,
    
    output reg [39:0] data,
    output reg valid
    );
    
    wire [9:0] fine1_out;
    wire [9:0] fine2_out; 
    wire [15:0] course_out;
    wire coarse_done;
    reg set;
    wire or_reset;
    wire fine1_stop;
    wire fine2_stop;
    
    or(or_reset, set, reset);
    
    edgeDetector Start (
        .clk(clk),
        .reset(or_reset),
        .level(start),
        .out(fine1_stop)
    );
    
    edgeDetector Stop (
        .clk(clk),
        .reset(or_reset),
        .level(stop),
        .out(fine2_stop)
    );
    
    fine_counter #(
        .x(46),
        .y(4)
        ) fine1 (
        .start(start),
        .stop(fine1_stop),
        .reset(or_reset),
        .clk(clk),
        .data(fine1_out)
    );
     
    fine_counter #(
        .x(47),
        .y(3)
        )  fine2 (
        .start(stop),
        .stop(fine2_stop),
        .reset(or_reset),
        .clk(clk),
        .data(fine2_out)
    );
    
    Coarse_Counter_22 coarse (
        .start(start),
        .stop(stop),
        .clk(clk),
        .data(course_out),
        .reset(or_reset)
    );
    
    //STATE MACHINE
    
    localparam [2:0]
        WAIT_FS =       3'b000,
        WAIT_FP =       3'b001,
        VALID =         3'b010,
        WAIT_FR =       3'b011,
        WAIT_FSub =     3'b100,
        WAIT_FSub2 =    3'b101
        ;
        
    reg [2:0] state, next;
      
    initial begin
        state <= WAIT_FS;
    end
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= WAIT_FS;
        end
        else begin
            state <= next;
        end
    end 
    
    always @(posedge clk) begin
        
        case (state)
            WAIT_FS : begin
                set = 1'b0;
                if(start == 1'b1) begin
                    next <= WAIT_FP;
                end
                else begin
                    next <= WAIT_FS;
                    valid <= 1'b0;
                end
            end
            
            WAIT_FP : begin
                if(stop == 1'b1) begin
                    next <= WAIT_FSub;
                end
                else begin
                    next <= WAIT_FP;
                    valid <= 1'b0;
                end
            end
            
            WAIT_FSub : begin
                next <= WAIT_FSub2;
            end
            
            WAIT_FSub2 : begin
                next <= VALID;
            end
            
            VALID : begin
                data[23:14] <= fine1_out[9:0];
                data[13:4] <= fine2_out[9:0];
                data[39:24] <= course_out[15:0];
                data[3:0] <= 4'b0101;
                valid <= 1'b1;
                next <= WAIT_FR;
            end
            
            WAIT_FR : begin
                valid <= 1'b0;
                set = 1'b1;
                if(start == 0 && stop == 0) begin
                    next <= WAIT_FS;
                end
                else begin
                    next <= WAIT_FR;
                end
            end
        endcase
    end
    
    
endmodule
