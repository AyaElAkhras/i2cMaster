// file: i2cMaster_top.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: i2cMaster_top.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This module represnts the complete i2c master as a black box 
 *  
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 
`timescale 1ns/1ns


// Note the following assumptions:
/*
  1. the entire system has an active low reset_n
  
  2. Mclk is equivalent to clk and both are considered to be the system's clk
  
  3. iSCL has a lower frequency than that of Mclk since we construct it from a clock_divider of frequency 1/2Mclk
  
  4. At some times, iSCL is adjusted to be flattened not a periodic signal. Specifically this occurs when there's an edge detected in busy 
  
  5. SCL is assigned iSCL to be outputted to the bus and slaves 
  
 

  Refer to the top of each module for some comments special to each module  


*/


module i2cMaster_top (clk, reset_n, Addr, DataIn, R_W, En, SDA, SCL, DataOut);     
    input clk;
    input reset_n;
    input [1:0] Addr;    // coming from CPU, targetting a specific I/O register from master
    input [7:0] DataIn;  // coming from CPU
    input R_W;   // from CPU; requesting either to read from Master or to write to it  if read yb2a is looking for dataout off the master, but if write yb2a pass address of where to write and the data to be written into the master
    
    input En;  // enable to allow the master to respond to R_W (Coming from CPU)
    
    
    inout SDA;   
    output SCL;   
    output [7:0] DataOut;
    
    // Outputted signals from control unit 
    wire done;
    wire success; 
    wire busy;
    wire newcount;
    wire abit;
    wire dbit; 
    wire inbar_out;         // the enable of the tristate buffer inside BIU to implement the logic of a inout port
    ///////////////////////////
    
   
    
    /////////////// Outputs of the CPU interface module
    wire en_AU;
    wire en_DU;
    wire en_go;
    wire [7:0] AU_input;
    wire [7:0] DU_input;
    /////////////
   
    wire iSCL;  // output from SSU and input to BIU
    wire iSDA; // output from BIU and input to ControlUnit_FSM (carries acknowledge)
    
    wire eight_bit;  // output of counter indicating that 8 cycles have passed
    
    
    
    
    /////////////////
    wire detect_pos;
    wire detect_neg;
    wire detect_edge;
    wire  mux_oSDA;  // this is a signal that will define the oSDA that'll be sent to SDA at any moment in time 

    wire AU_oSDA;
    wire DU_oSDA;
    

    
    wire count_reset;
    
    // Output SCL and handle the idea of SDA being inout
    BIU Bus_Interface_Unit (.inbar_out(inbar_out), .iSCL(iSCL), .oSDA(mux_oSDA), .SDA(SDA), .iSDA(iSDA), .SCL(SCL));   
    
    CPU_Interface_handler  CPU (.Addr(Addr), .DataIn(DataIn), .R_W(R_W), .En(En),  .success(success), .done(done),  .DataOut(DataOut), .en_AU(en_AU), .en_DU(en_DU), .en_go(en_go), .AU_input(AU_input), .DU_input(DU_input) );

    AU  Address_Unit (.clk(clk), .reset_n(reset_n), .abit(abit), .load_en(en_AU & !busy), .AddrIn(AU_input), .detect_pos(detect_pos), .iSCL(iSCL),  .oSDA(AU_oSDA) );
    
    DU  Data_Unit (.clk(clk), .reset_n(reset_n), .dbit(dbit), .load_en(en_DU & !busy), .data(DU_input), .iSCL(iSCL), .oSDA(DU_oSDA) );
    

    SSU Start_Stop_Unit ( .Mclk(clk), .reset_n(reset_n), .busy(busy), .detect_pos(detect_pos), .detect_neg(detect_neg),   .iSCL(iSCL) );
    
    Up_Counter  Master_count (.clk(clk), .reset_n(reset_n & count_reset), .en(iSCL & newcount), .eight_bits(eight_bit));
    

    ControlUnit_FSM   Master_controlUnit ( .clk(clk), .reset_n(reset_n), .go(en_go), .eight_bit(eight_bit), .iSDA(iSDA), .iSCL(iSCL), .detect_neg(detect_neg),  .busy(busy), .newcount(newcount), .abit(abit), .dbit(dbit), 
                                            .done(done), .success(success) , .inbar_out(inbar_out) ,  .count_reset(count_reset));


    EdgeDetector    my_detector (.clk(clk), .reset_n(reset_n), .signal(busy), .detect_pos(detect_pos), .detect_neg(detect_neg), .detect_edge(detect_edge) ); 
    

    assign  mux_oSDA = (detect_edge) ? 1'b0 : (abit) ? AU_oSDA : (dbit) ? DU_oSDA : 1'b1;   


endmodule




