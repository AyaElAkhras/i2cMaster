// file: CPU_Interface_handler.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: CPU_Interface_handler.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This is meant to handle the CPU requests from master
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 
// Assumptions 
/*
    1. Since the address of a slave, serially outputted to the i2c bus in AU module is 7 bits, but the datain coming from the CPU is 
        8 bits, I assumed that the MSB is not of any importance then I concatenated the remaining bits with 0 to model R/W = 0 for a command of writing to 
        this slave address
        
    2. What enables loading to AU or DU is when the master isn't busy (!busy) and when the CPU is requesting to write to the address of AU or DU 

    3. Note that I'm loading DataOut the entire time however we should only care for results when R_W = 1 and when Addr = 11 indicating that the CPU is requesting read from STATUS

*/



`timescale 1ns/1ns

module CPU_Interface_handler(Addr, DataIn, R_W, En, success, done,  DataOut, en_AU, en_DU, en_go, AU_input, DU_input);
   input [1:0] Addr;
   input [7:0] DataIn;
   input R_W;
   input En;
   
   input success;
   input done;
   
   output [7:0] DataOut;
   output en_AU;  // to decide when the data passed by the CPU to the i2c master will be loaded to AU
   output en_DU;  // to decide when the data passed by the CPU to the i2c master will be loaded to DU
   output en_go;  // a signal that when raised to 1 indicates that the CPU is asking the i2c master to start a transaction with the i2c slave
   
   output [7:0] AU_input;   
   output [7:0] DU_input;
   
   assign AU_input = {DataIn[6:0], 1'b0};
   assign DU_input = DataIn;
   assign en_go = ( (Addr == 2'b10) & DataIn[0] & !R_W & En );
   assign en_AU = ( (Addr == 2'b00) & !R_W & En );
   assign en_DU = ( (Addr == 2'b01) & !R_W & En );
   

    assign DataOut = {6'b0, success, done};
    
endmodule


