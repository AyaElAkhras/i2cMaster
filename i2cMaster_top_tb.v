// file: i2cMaster_top_tb.v
// author: @ayaelakhras
// Testbench for i2cMaster_top

`timescale 1ns/1ns

module i2cMaster_top_tb;

	//Inputs
	reg clk;
	reg reset_n;
	reg [1: 0] Addr;
	reg [7: 0] DataIn;
	reg R_W;
	reg En;


	//Outputs
	wire SCL;
	wire [7: 0] DataOut;
	
	
	//inouts requirements
	wire SDA;
	wire SDA_output_from_master;
	reg SDA_output_from_slave;
    reg en_inout;    // this will be triggered in different events to allow SDA port to act as input at moments and as output at others 

	//Instantiation of Unit Under Test
	i2cMaster_top uut (
		.clk(clk),
		.reset_n(reset_n),
		.Addr(Addr),
		.DataIn(DataIn),
		.R_W(R_W),
		.En(En),
		.SDA(SDA),
		.SCL(SCL),
		.DataOut(DataOut)
	);

    
    // Logic of inout  is opposite to what's inside 
    assign SDA = (en_inout) ? SDA_output_from_slave : 1'bz;
    assign SDA_output_from_master = SDA;
    
    
    integer i; // index of loop 
    reg[7:0] address_to_slave_in = 8'b11100011;
    reg [7:0] address_after_change = 8'b11000110;
    reg[7:0] data_to_slave_in = 8'b00001111;
    
    reg data_bits_error;
    reg address_bits_error;
    reg status_success_error;
    reg status_failure_error;
    
   /////////////////////// Actual big test case  
   
    always #5 clk = !clk;

    initial begin 
    
    //Inputs initialization
		clk = 0;
		reset_n = 0;
		Addr = 0;
		DataIn = 0;
		R_W = 0;     // default is CPU write to master
		En = 0;      // default is not to enable all CPU commands
        
        en_inout = 0;   // default is output from master

	//Wait for the reset
		#20 reset_n = 1;
    
    
    
       -> TEST1;
       @(TEST1_end);
        
       //#60;
       
     
        

        
        -> TEST2;
        @(TEST2_end);
        
         // -> golden_verify;
      // @(golden_verify_end);
       
       
      
    end 

/////////////////////////////////

     event TEST2;
     event TEST2_end;
	 initial begin
	    @(TEST2);
	   
	    ->go_trigger;
	    @(go_done_trigger);
	 
	  
		-> ack_success_trigger;
		-> check_addressBits;
         @(check_addressBits_end);
	   	@(ack_success_done_trigger);
		
	// check for data

          
        
	    
        @(SDA===1'bz);
       // @(posedge clk);
		-> ack_success_trigger;     // to send acknowledge for data 
		  -> check_dataBits;
            @(check_dataBits_end);
		    @(ack_success_done_trigger);
		
		#40;
	    -> CPU_check_transaction;
	    	@(CPU_check_done_transaction);
	    
	     -> check_dataout_status_success;
        @(check_dataout_status_success_end);	

        -> TEST2_end;
	end
	

///////////////////////////////////

    event TEST1;
    event TEST1_end;
	initial begin
	    @(TEST1);
    	->address_load;
		 @(address_done_load);
		

         -> data_load;
	     @(data_done_load);

    	-> go_trigger;
	    @(go_done_trigger);  

       
        
        ->ack_fail_trigger;
        -> check_addressBits;

        @(check_addressBits_end);
        @(ack_fail_done_trigger);
        

       
         -> CPU_check_transaction;
	    @(CPU_check_done_transaction);
	                            

	    
	     -> check_dataout_status_failure;
        @(check_dataout_status_failure_end);	
	    	                

	    	

        -> TEST1_end; 
	end
	
//////////////

    event address_load;
    event address_done_load;
    initial 
    forever begin
        @(address_load);
        @(posedge clk);
		 En = 1'b1;
		 R_W = 1'b0; // CPU wants to write 
		 Addr = 2'b00;
		 DataIn = address_to_slave_in;
		
		@(posedge clk);
        En = 1'b0;
        
        -> address_done_load;
    end 
///////////

    event data_load;
    event data_done_load;
    initial 
    forever begin
        @(data_load);
        @(posedge clk);
		 En = 1'b1;
		 R_W = 1'b0; // CPU wants to write 
		 Addr = 2'b01;
		 DataIn = data_to_slave_in;
		 
		 @(posedge clk)
		 En = 1'b0;
		 
        -> data_done_load;
    end 

/////////////////

	event go_trigger;
	event go_done_trigger;
	initial 
	forever begin
	    @(go_trigger);
	    @(posedge clk);
	    En=1'b1;
	    R_W = 1'b0;
	    Addr = 2'b10;
	    DataIn = 8'b01;
	    
	    @(posedge clk);
	    En = 1'b0;
	    
	    -> go_done_trigger;
	end 


//////////
    event ack_success_trigger;
    event ack_success_done_trigger;
    initial 
    forever begin
        @(ack_success_trigger);
         repeat (17) begin
           @(posedge clk);
        end 

        en_inout = 1'b1;
        SDA_output_from_slave = 1'b0;
        
        @(posedge clk);
        en_inout = 1'b0;
        
        -> ack_success_done_trigger;
    end
    
    
    
  

///////////

    event ack_fail_trigger;
    event ack_fail_done_trigger;
    initial 
    forever begin
        @(ack_fail_trigger);
        repeat (17) begin
            @(posedge clk);
        end 
        en_inout = 1'b1;
        SDA_output_from_slave = 1'b1;
        
        @(posedge clk);
        en_inout = 1'b0;
        
        -> ack_fail_done_trigger;
    end
    
//////////

    event CPU_check_transaction;
    event CPU_check_done_transaction;
    initial
    forever  begin
        @(CPU_check_transaction)
        @(posedge clk)
        En = 1'b1;
        R_W = 1'b1;
        Addr = 2'b11;
        @(posedge clk)
        En = 1'b0;
        R_W = 1'b0;
        -> CPU_check_done_transaction;
    end 
    
    
    
///////////////

    event check_addressBits;
    event check_addressBits_end;
    initial 
    forever  begin
        @(check_addressBits);
                i = 7;
                repeat(7) begin
                   @(posedge SCL);
                    if(address_after_change[i] != SDA)
                        address_bits_error= 1'b1;
                    else
                        address_bits_error = 1'b0;
                   
                    i = i-1;
                end 
        ->check_addressBits_end;
    end 
    
///////////////////


    event check_dataBits;
    event check_dataBits_end;
    initial 
    forever  begin
        @(check_dataBits);
             i = 7;
                repeat(7) begin
                   @(posedge SCL);
                    if(data_to_slave_in[i] != SDA)
                        data_bits_error= 1'b1;
                    else
                        data_bits_error = 1'b0;
                   
                    i = i-1;
                end 

        ->check_dataBits_end;
    end 

///////////////////


    event check_dataout_status_success;      // success = 1
    event check_dataout_status_success_end;
    initial 
    forever begin 
        @(check_dataout_status_success);
         @(posedge clk);
            if(DataOut[1:0] != 2'b11)
                status_success_error = 1'b1;
            else
                status_success_error = 1'b0;
        -> check_dataout_status_success_end;
    end


///////////

    event check_dataout_status_failure;
    event check_dataout_status_failure_end;
    initial 
    forever begin 
        @(check_dataout_status_failure);
            @(posedge clk);
            if(DataOut[1:0] != 2'b01)
                status_failure_error = 1'b1;
            else
                status_failure_error = 1'b0;
        -> check_dataout_status_failure_end;
    end

////////////////


 // Checker 
// event golden_verify;
// event golden_verify_end;
    //initial 
    //forever  begin 
   // @(golden_verify);
   always  @(posedge clk)  begin   
           if(address_bits_error)  begin 
                $display ("DUT Error at time %d", $time); 
    	        $display ("Expected bit of address should be  %d, Got Value %d", address_after_change[i], SDA); 
            end 
            
            else  begin   
                if(data_bits_error)  begin 
                    $display ("DUT Error at time %d", $time); 
    	            $display ("Expected bit of address should be  %d, Got Value %d", data_to_slave_in[i], SDA); 
            
                end 
                
                else  
                    if(status_failure_error || status_success_error) begin 
                         $display ("DUT Error at time %d", $time); 
    	                 $display ("Got the status from master wrong "); 
                    end 
                    
                    else
                       $display ("Bravooo"); 

            end 
  //  -> golden_verify_end;        // add bravo if else 
    end 
       
        
    
    
endmodule



