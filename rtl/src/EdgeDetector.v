`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/28/2022 03:31:36 PM
// Design Name: 
// Module Name: EdgeDetector
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


module EdgeDetector
(
    input wire clk, reset, 
    input wire level, 
    output reg out
);

localparam
    zeroMealy = 1'b0,
    oneMealy =  1'b1;


reg stateMealy_reg, stateMealy_next; 

always @(posedge clk, posedge reset)
begin
    if(reset)
        begin
        stateMealy_reg <= zeroMealy;
        end
    else
        begin
        stateMealy_reg <= stateMealy_next;
        end
end


always @(stateMealy_reg, level)
begin
    stateMealy_next = stateMealy_reg;
    
    out = 1'b0;
    case(stateMealy_reg)
        zeroMealy:
            if(level)  
                begin 
                    stateMealy_next = oneMealy;
                    out = 1'b1;
                end
        oneMealy: 
            if(~level)
                stateMealy_next = zeroMealy;
    endcase
end

endmodule
