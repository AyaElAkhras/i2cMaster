// file: EdgeDetector.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: EdgeDetector.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This module detects a rising or falling edge of my signal 
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 


`timescale 1ns/1ns

module EdgeDetector(clk, reset_n, signal, detect_pos, detect_neg, detect_edge);
    input clk;
    input reset_n;
    input signal;
    output  detect_pos;
    output detect_neg;
    output detect_edge;
    
    reg sig;
    wire detect_edge_temp;
    
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n)
            sig <= 1'b0;
            
        else
            sig <= signal;
            
    end
    
    assign detect_edge_temp = (signal  ^ sig);
    assign detect_pos =  detect_edge & signal;
    assign detect_neg = detect_edge & sig;
    
    assign detect_edge = detect_edge_temp;
    

endmodule

