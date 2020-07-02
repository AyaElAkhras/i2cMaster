// file: AU.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: AU.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This module loads the address and the R/W bit on go and shifts them out serially to oSDA when abit is true
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 

`timescale 1ns/1ns

module AU(clk, reset_n, abit, load_en, AddrIn, detect_pos, iSCL, oSDA);     
    input clk;
    input reset_n;
    input abit;
    input load_en;
    input [7:0] AddrIn;
    input detect_pos;
  
    input iSCL;
    
    output  oSDA;  // bits serially outputted
    reg [7:0] temp;

    always @(posedge clk or negedge reset_n)  begin
        if(!reset_n)
            temp <= 8'b0;
       
        else   begin
            if(load_en)  // by this condition I'm sure that the CPU is allowing AU to be loaded with the inputted data and that we aren't in the middle of a transaction 
                temp <= AddrIn;   // parallel loading
                
            else begin
                if(abit & iSCL & !detect_pos )     
                        temp <= {temp[6:0], temp[7]};   // serial output by shifting to the left
                        

                else
                    temp  <= temp;
                    
            end
        end
            
        
    
    end
    
    assign oSDA =  temp[7] ;
    
endmodule


