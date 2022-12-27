`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.08.2022 16:04:15
// Design Name: 
// Module Name: tx_module
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


module UART #(
  parameter baudRate = 9600,
  parameter clkFreq = 132000000
)(
  input logic clk,
  input logic reset,
  input logic[7:0] data,                            
  input logic send_trigger,
  
  output logic signal,
  output logic done
//  output logic rts,
//  output logic debug_1,
//  output logic debug_2,
//  output logic debug_3,
//  output logic debug_4
);


//assign rts = 0;
//assign send_trigger = 1;

//initial debug_1 = 1'b0;
//initial debug_2 = 1'b0;
//initial debug_3 = 1'b0; 
//initial debug_4 = 1'b0;
//initial debug_1 = 1'b0;

//wire clk;
//reg done;

typedef enum { IDLE, START_BIT, DATA_BITS, STOP_BIT, DONE } State;
State uart_send_state = IDLE;

int count = 0;
int clkPulsesPerBit = clkFreq / baudRate;
int bits_send = 0;
logic[7:0] dataToSend;
logic startTransmission = 0;

//always @(send_trigger) begin
//    debug_1 <= 1'b1;
//end


//always @(posedge send_trigger) begin
//    trig <= 1;
//end

//always @(negedge clk) begin
//    trig <= 0;
//end


always @(posedge clk) begin
  count <= count + 1;

  case (uart_send_state)
    IDLE: begin
      signal <= 1;

      if (send_trigger == 1) begin
        uart_send_state <= START_BIT;
        count <= 0;
        dataToSend <= data;
        
//        debug_2 <= 1;
      end
    end
    START_BIT: begin
      signal <= 0;
        
//        debug_1 <= 1;
        
      if (count == clkPulsesPerBit) begin
        uart_send_state <= DATA_BITS;
        bits_send <= 0;
        count <= 0;
      end
    end
    DATA_BITS: begin
      signal <= dataToSend[bits_send];
      
//      debug_3 <= signal;
      
      if (count == clkPulsesPerBit) begin
        count <= 0;
        bits_send <= bits_send + 1;

        if (bits_send == 7) begin
          uart_send_state <= STOP_BIT;
        end
      end
    end
    STOP_BIT: begin
      signal <= 1;

      if (count == clkPulsesPerBit) begin
        count <= 0;
        done <= 1;
        uart_send_state <= DONE;
      end
    end
    DONE : begin
        done <= 0;
        uart_send_state <= IDLE;
    end
    default: uart_send_state <= IDLE; 
  endcase
end
endmodule

