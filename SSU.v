// file: SSU.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: SSU.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This module 
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 

`timescale 1ns/1ns

module SSU ( Mclk, reset_n, busy, detect_pos, detect_neg,  iSCL );
    input Mclk;     
    input reset_n;
    input busy;
    
    
    ///////
    input detect_pos;
   input detect_neg;


    output iSCL;

   
    wire temp_iSCL;
    
    

    ClockDivider my_divider (.clk(Mclk), .reset_n(reset_n), .busy(busy),  .iSCL(temp_iSCL) );
    
    assign iSCL = (!busy) ? 1'b1 : temp_iSCL;   // Since I assume that in reset state (idle state) iSCL is set to 1 (flattened) 
   

endmodule

