`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2022 03:48:48 PM
// Design Name: 
// Module Name: tdctest
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


module topteset();

    reg clk_p;
    reg clk_n;
//    reg en;
    reg start;
    reg stop;
    reg enable;
    reg reset;
//    reg t;
    
    wire [39:0] TDC_out;
    wire valid;
    wire out;
    integer f,j;
    real i;

    
    TOP test (
        .clk_p(clk_p),
        .clk_n(clk_n),
        .start (start),
        .stop (stop),
        .reset_button(reset),
        .enable(enable),
        .tx(out)
    );

//    fine_tdc test (
//        .trigger (start),
//        .clock (clk_p),
//        .latched_output (out)
//    );
    
    initial begin
        clk_p = 1'b1;
        forever #2.5 clk_p = ~clk_p;
    end   

    initial begin
        clk_n = 1'b0;
        start = 1'b0;
        stop = 1'b0;
        forever #2.5 clk_n = ~clk_n;
    end   
    
//    initial begin
//        forever #100000 start = ~start;
//    end

//    initial begin
//        #100
//        forever #100000 stop = ~stop;
//    end
    initial begin
    
        #10
        enable = 0; 
        start = 0;
        stop = 0;
        reset = 0;
        #500
        reset = 1;
        #30
        reset = 0;
        #394.75
        for (j = 1; j<500; j = j+1) begin
        
            #200
            start = 1;
            #j
            stop = 1;
            #15
            stop = 0;
            start = 0;

        end
        

//        for (i = 0.01; i<1; i=i+0.05) begin
//            #50
            
//            #i
//            start = 1;
//            #5
//            stop = 1;
//            #15
//            stop = 0;
//            start = 0;
            
            
//        end

//    end
    
//    always @(posedge valid) begin
//        f = $fopen("output.txt","a");
//            $fwrite(f,"%b\n",TDC_out);
//            $fclose(f);        
        end
endmodule