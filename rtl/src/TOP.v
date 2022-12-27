`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2022 02:39:49 PM
// Design Name: 
// Module Name: TOP
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


module TOP(
    input clk_p,
    input clk_n,
    input start,
    input stop,
    input reset_button,
    input enable,
  
    output tx
//    output reg [0:7] leds
//    output [39:0] TDC_out,
//    output val
    );
    
    wire clk;
    wire UART_done;
    wire empty;
    wire valid;
    
    reg reset;
    reg [7:0] bus_8bit;
    wire [39:0] din_40bit;
    wire [39:0] dout_40bit;
    reg [39:0] buffer;
    reg UART_trigger;
    reg wr_en;
    reg rd_en;
    reg FIFO_reset;
    
    clk_wiz_0 clock (
        .clk_out1 (clk),
        .reset (),
        .locked (),
        .clk_in1_p (clk_p),
        .clk_in1_n (clk_n)
    );
    
    UART transmitter (
        .clk(clk),
        .reset(reset),
        .data(bus_8bit),
        .send_trigger(UART_trigger),
        .signal(tx),
        .done(UART_done)
    ); 
    
    fifo_generator_0 fifo (
      .clk(clk),      // input wire clk
      .srst(FIFO_reset),    // input wire srst
      .din(din_40bit),      // input wire [39 : 0] din
      .wr_en(wr_en),  // input wire wr_en
      .rd_en(rd_en),  // input wire rd_en
      .dout(dout_40bit),    // output wire [39 : 0] dout
      .full(),    // output wire full
      .empty(empty)  // output wire empty
    );
    
    TDC main (
        .start(start),
        .stop(stop),
        .clk(clk),
        .data(din_40bit),
        .valid(valid),
        .reset(reset)
    );
    
    //State Machine
    localparam [3:0]
        initialize =    4'b0000,
        waiting =       4'b0001,
        fetch_1 =       4'b0010,
        fetch_2 =       4'b0011,
        send_1 =        4'b0100,
        send_1_w =      4'b0101,
        send_2 =        4'b0110,
        send_2_w =      4'b0111,
        send_3 =        4'b1000,
        send_3_w =      4'b1001,
        send_4 =        4'b1010,
        send_4_w =      4'b1011,
        send_5 =        4'b1100,
        send_5_w =      4'b1101 
        ;
        
    localparam [1:0]     
        reset_1 =       2'b10,
        reset_2 =       2'b11
        ;
        
    localparam [1:0]
        state_1 =       2'b00,
        state_2 =       2'b01
        ;
           
    localparam [2:0] 
        LIGHT1 =    3'b000,
        LIGHT2 =    3'b001,
        LIGHT3 =    3'b010,
        LIGHT4 =    3'b011,
        LIGHT5 =    3'b100,
        LIGHT6 =    3'b101,
        LIGHT7 =    3'b110,
        LIGHT8 =    3'b111
        ;    
        
    localparam TIME = 132000000/3;    
    
    reg [1:0] state_valid, next_valid;
    reg [1:0] state_reset, next_reset;
    reg [3:0] state, next;
    reg [2:0] state_lights, next_lights;
    reg [26:0] light_counter;
    reg [4:0] timer_f;
    
//    assign TDC_out = buffer;
//    assign val = valid;

//    assign din_40bit = 40'b0000000000111111111100000000001111111111;
    
    initial begin 
        state_reset = reset_1;
        light_counter = 0;
    end
    
//    // timer 
//    always @(posedge clk, posedge reset) begin 
//        if (reset) begin
//            light_counter <= 0;
//        end
//        else begin
//            if(state_lights != next_lights) begin  // state is changing
//                light_counter <= 0;
//            end
//            else begin
//                light_counter <= light_counter + 1;  
//            end
//        end
//    end
    
//    always @(posedge clk) begin
//        next_lights = state_lights;
//        case(state_lights)
//            LIGHT1 : begin
//                leds = 8'b10000001;
//                if(light_counter >= TIME) begin
//                        next_lights = LIGHT2;
//                end
//            end
            
//            LIGHT2 : begin
//                leds = 8'b01000010;
//                if(light_counter >= TIME) begin
//                    next_lights = LIGHT3;  
//                end
//            end
            
//            LIGHT3 : begin
//                leds = 8'b00100100;
//                if(light_counter >= TIME) begin
//                    next_lights = LIGHT4;
//                end
//            end
            
//            LIGHT4 : begin
//                leds = 8'b00011000;
//                if(light_counter >= TIME) begin
//                    next_lights = LIGHT5;
//                end
//            end

//            LIGHT5 : begin
//                leds = 8'b00100100;
//                if(light_counter >= TIME) begin
//                        next_lights = LIGHT6;
//                end
//            end
            
//            LIGHT6 : begin
//                leds = 8'b01000010;
//                if(light_counter >= TIME) begin
//                    next_lights = LIGHT1;  
//                end
//            end
                             
//        endcase
//    end
            
    always @(posedge clk) begin
        state_reset <= next_reset;
    end

    always @(posedge clk) begin
        case (state_reset)
            reset_1 : begin
                if(reset_button == 1'b1) begin
                    reset <= 1'b1;
                    next_reset <= reset_2;
                end
                else begin
                    next_reset <= reset_1;
                end
            end
                
            reset_2 : begin
                reset = 1'b0;
                if(reset_button == 1'b0) begin
                    next_reset <= reset_1;
                end
                else begin
                    next_reset <= reset_2;
                end
            end
        endcase         
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= initialize;
            state_valid <= state_1;
            state_lights <= LIGHT1;
        end
        else begin
            state <= next;
            state_valid <= next_valid;
            state_lights <= next_lights;
            
        end
    end 
    
    always @(posedge clk, posedge reset) begin 
        if (reset) begin
            timer_f <= 0;
        end
        else begin
            if (state != next) begin 
                timer_f <= 0;
            end
            else begin
                timer_f <= timer_f + 1;  
            end
        end
    end
    
    always @(posedge clk) begin        
        case (state_valid)
            state_1 : begin
                if((valid == 1'b1) && (enable == 1'b0)) begin
                    wr_en <= 1'b1;
                    next_valid <= state_2;
                end
                else begin
                    next_valid = state_1;
                end
            end
                
            state_2 : begin
                wr_en = 1'b0;
                next_valid = state_1;
            end            
        endcase         
    end
    
    always @(posedge clk) begin
        
        case (state) 
            initialize : begin
                if(timer_f >= 5) begin
                    FIFO_reset <= 0;
                    next <= waiting;
                end
                else begin
                    FIFO_reset <= 1;
                    next <= initialize;
                end
            end         
            
            waiting : begin
                if(empty) begin
                    next <= waiting;
                end
                else begin 
                    next <= fetch_1;
                end
            end
            
            fetch_1 : begin
                rd_en = 1'b1;
                next <= fetch_2;
            end
            
            fetch_2 : begin
                buffer <= dout_40bit;
                rd_en = 1'b0;
                next = send_1;
            end
            
            send_1 : begin
                bus_8bit <= buffer[39:32];
                UART_trigger = 1'b1;
                next = send_1_w;
            end
            
            send_1_w : begin
                UART_trigger <= 1'b0;
                if(UART_done) begin
                    next <= send_2;
                end
                else begin
                    next <= send_1_w;
                end
            end
            
            send_2 : begin
                bus_8bit = buffer[31:24];
                UART_trigger = 1'b1;
                next <= send_2_w;
            end       
            
            send_2_w : begin
                UART_trigger <= 1'b0;
                if(UART_done) begin
                    next <= send_3;
                end
                else begin
                    next <= send_2_w;  
                end
            end
            
            send_3 : begin
                bus_8bit = buffer[23:16];
                UART_trigger = 1'b1;
                next <= send_3_w;
            end       
            
            send_3_w : begin
                UART_trigger <= 1'b0;
                if(UART_done) begin
                    next <= send_4;
                end
                else begin
                    next <= send_3_w;  
                end
            end
            
            send_4 : begin
                bus_8bit = buffer[15:8];
                UART_trigger = 1'b1;
                next <= send_4_w;
            end       
            
            send_4_w : begin
                UART_trigger <= 1'b0;
                if(UART_done) begin
                    next <= send_5;
                end
                else begin
                    next <= send_4_w;  
                end
            end
            
            send_5 : begin
                bus_8bit = buffer[7:0];
                UART_trigger = 1'b1;
                next <= send_5_w;
            end       
            
            send_5_w : begin
                UART_trigger <= 1'b0;
                if(UART_done) begin
                    next <= waiting;
                end
                else begin
                    next <= send_5_w;  
                end
            end
        endcase
    end

endmodule
