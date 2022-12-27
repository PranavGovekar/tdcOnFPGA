`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2022 11:09:01 AM
// Design Name: 
// Module Name: fine_counter
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


module fine_counter(
    input start,
    input stop,                 //clock
    input reset,
    input clk,
    
    output [9:0] data
    );
    
    parameter x = 0 ,y = 0;
    
    wire [1023:0] out_bus;
    reg flag_read;
    reg enable;
    
    fine_tdc #(
    .Xoff(x),
    .Yoff(y))
     fine 
     (
        .trigger(start),
        .reset(reset),
        .clock(stop),
        .latched_output(out_bus)
    );
    
    encoder encode(
        .clk(enable),
        .op(out_bus),
        .en_op(data)
    );
    
//        STATE MACHINE
    
    localparam [2:0]
        WAIT_FS =       3'b000,
        HOLD =          3'b001,
        HOLD2 =         3'b010,
        HOLD3 =         3'b011
        ;
        
    reg [2:0] state, next;
    
    initial begin
        state = WAIT_FS;
    end
    
    always @(posedge clk) begin
        if (reset) begin
            state <= WAIT_FS;
        end
        else begin
            state <= next;
        end
    end
    
    always @ (posedge clk) begin
        case(state)
            WAIT_FS : begin
                enable = 0;
                if(start == 1) begin
                    next = HOLD;    
                end
                else begin
                    next = WAIT_FS;
                end
            end
            
            HOLD : begin
                enable = 1;
                next = HOLD3;
            end               
            
            HOLD3 : begin
                enable = 0;
                if(start == 0) begin
                    next = WAIT_FS;
                end
                else begin
                    next = HOLD3;
                end
            end
        endcase
    end
endmodule
