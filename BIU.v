// file: BIU.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: BIU.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This module 
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 

`timescale 1ns/1ns

module BIU(inbar_out, iSCL, oSDA, SDA, iSDA, SCL);
    input inbar_out;
    input iSCL;
    input oSDA;    // data to be outputted to the slave arrive here and shall be passed to SDA
    
    inout SDA;

    output iSDA;  // data inputted from the slave will be put here
    output SCL;
    
    
    
   // Tristate buffer logic to control the behavior of inout port      
   assign iSDA =  SDA;
   assign SDA = (inbar_out) ? oSDA: 1'bz;

   assign SCL = iSCL;    



endmodule

