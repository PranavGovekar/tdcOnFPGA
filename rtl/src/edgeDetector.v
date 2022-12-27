`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2022 06:24:26 PM
// Design Name: 
// Module Name: edgeDetector
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


module edgeDetector
(
    input wire clk, reset, 
    input wire level, 
    output reg out
);

localparam [1:0] // 3 states are required for Moore
    zeroMoore = 2'b00,
    edgeMoore = 2'b01, 
    oneMoore = 2'b10,
    delay = 2'b11;

reg[1:0] stateMoore_reg, stateMoore_next;

always @(posedge clk, posedge reset)
begin
    if(reset) // go to state zero if rese
        begin
        stateMoore_reg <= zeroMoore;
        end
    else // otherwise update the states
        begin
        stateMoore_reg <= stateMoore_next;
        end
end

// Moore Design 
always @(stateMoore_reg, level)
begin
    // store current state as next
    stateMoore_next = stateMoore_reg; // required: when no case statement is satisfied
     // set tick to zero (so that 'tick = 1' is available for 1 cycle only)
    case(stateMoore_reg)
        zeroMoore: // if state is zero,
            if(level) // and level is 1
                stateMoore_next = edgeMoore; // then go to state edge.
        edgeMoore:
            begin
                out = 1'b1;
                stateMoore_next = oneMoore;
            end
        oneMoore: begin
            out = 1'b0;
            if (~level) 
                stateMoore_next = zeroMoore; // then go to state zero.      
        end
    endcase
end
endmodule
