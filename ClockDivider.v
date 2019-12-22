// file: ClockDivider.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: ClockDivider.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This module is a clock divider responsible for generating an internal clk signal that is half the frequency of the system clk 
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 


`timescale 1ns/1ns

module ClockDivider(clk, reset_n, busy,  iSCL);     // suppose that it outputs its divided clk into 2 wires clk and iSCL..   
    input clk;
    input reset_n;
    input busy;
    
    output iSCL;
    
    wire qbar;
    
    DFF_ClockDivider  divider (.clk(clk), .reset_n(reset_n & busy), .en(1'b1), .d(qbar), .q(iSCL), .qbar(qbar) );    
    


endmodule

