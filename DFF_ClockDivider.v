// file: DFF_ClockDivider.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: DFF_ClockDivider.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: It a D flip flop that will be used to construct a clock divider, note that it resets its value to 1 
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 


`timescale 1ns/1ns

module DFF_ClockDivider(clk, reset_n, en, d, q, qbar);
    input clk;
    input reset_n;
    input en;
    input d;
    output reg q;
    output qbar;

    always@(posedge clk or negedge reset_n)
        if(reset_n) begin 
            if(en)
                q <= d;
               
            else
                q<= q;    // keep the same old value 
        end 
            
        else q <= 1'b1;    // Reset the clk outputted from the clk divider with 1
       

    assign qbar = ~q; 
    
endmodule

