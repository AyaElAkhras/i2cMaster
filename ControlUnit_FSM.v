// file: ControlUnit_FSM.v
// author: @ayaelakhras

/******************************************************************* 
 *  
 * Module: ControlUnit_FSM.v 
 * Project: i2cMaster
 * Author: Aya ElAkhras,   ayaelakhras@aucegypt.edu
 * Description: This models a FSM of the system 
 *
 * Change history: 02/11/18 – Started Working  
 *                 10/29/17 – Did something else 
 *  
 **********************************************************************/ 

// Assumptions
/*
    I assume that after transmitting a byte to the bus, if acknowledge = 1 (active low) then the transaction is ended up with success = 0

*/


`timescale 1ns/1ns

module ControlUnit_FSM( clk, reset_n, go, eight_bit, iSDA, iSCL,  detect_neg, busy, newcount, abit, dbit, done, success , inbar_out,  count_reset );
    input clk;
    input reset_n;
    input go;
    input eight_bit;
    input iSDA;
    input iSCL;
    
    input detect_neg;

    output busy;
    output newcount;   // enabler of counter 
    output abit;
    output dbit;
    output done;
    output success;
    
    output inbar_out;   // enabler of the tristate buffer handling the inout SDA port 
    


    output count_reset;

    reg [2:0] current_state, next_state;
    
     // states declaration
    parameter IDLE_STATE = 3'b000;
    parameter ADDRESS_STATE = 3'b001;
    parameter ACK_ADDR_STATE = 3'b010;
    parameter DATA_STATE = 3'b011;
    parameter ACK_DATA_STATE = 3'b100;
    parameter FAIL_FINISH_STATE = 3'b101;       
    parameter SUCCESS_FINISH_STATE = 3'b110;      
    
    // state register- sequential logic
    always@(posedge clk or negedge reset_n)
       if(!reset_n)
            current_state <= IDLE_STATE;    
       else 
            current_state <= next_state;
            
            
    // next state Logic- Combinational logic     
    always@(go or eight_bit or iSDA or current_state or iSCL) begin
        case (current_state)
            IDLE_STATE:
                if(go) 
                    next_state = ADDRESS_STATE;
                else
                    next_state = IDLE_STATE;
            
            
            ADDRESS_STATE:
                if(eight_bit && iSCL)   
                    next_state = ACK_ADDR_STATE;
                else
                    next_state = ADDRESS_STATE;
                    
                    
 
            ACK_ADDR_STATE:    // in this state, we automatically made the inout act as input so we need to check iSDA
                if(iSDA )     // active low acknowledge 
                    next_state = FAIL_FINISH_STATE;
                else 
                    next_state = DATA_STATE;
            
            DATA_STATE:
                if(eight_bit && iSCL)
                    next_state = ACK_DATA_STATE;
                else
                    next_state = DATA_STATE;
                    
            
            ACK_DATA_STATE:
                if(iSDA)
                    next_state = FAIL_FINISH_STATE;
                else
                    next_state = SUCCESS_FINISH_STATE;
                    
            
            FAIL_FINISH_STATE:
                if(go && !detect_neg)
                    next_state = ADDRESS_STATE;  
                
                else
                    next_state = FAIL_FINISH_STATE;
            
            SUCCESS_FINISH_STATE:
                 if(go && !detect_neg)
                    next_state = ADDRESS_STATE;  
                
                else
                    next_state = SUCCESS_FINISH_STATE;
            
            
            default: next_state = IDLE_STATE;
            
        endcase
    
    end
    

    
    // output logic
    assign busy = ( (current_state == IDLE_STATE) || (current_state == FAIL_FINISH_STATE) || (current_state == SUCCESS_FINISH_STATE) ) ? 0: 1;
    assign newcount = ((current_state == DATA_STATE) || (current_state == ADDRESS_STATE));   // enabler of the counter 
    assign abit = (current_state == ADDRESS_STATE);
    assign dbit = (current_state == DATA_STATE) ;
    
    assign done = ((current_state == FAIL_FINISH_STATE) || (current_state == SUCCESS_FINISH_STATE) );   
    
    assign success = (current_state == SUCCESS_FINISH_STATE) ;    
    
    assign inbar_out = ((current_state == ACK_ADDR_STATE) || (current_state == ACK_DATA_STATE)) ? 0:1;   // the only situation we need SDA to act as an input is in the acknowledge state when we wait for ack signal
                                                                                                                    // from iSDA


   assign count_reset = (current_state == ACK_ADDR_STATE || current_state == ACK_DATA_STATE) ? 0 :1;  // active low
   

endmodule





