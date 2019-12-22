// file: Up_Counter.v
// author: @ayaelakhras

`timescale 1ns/1ns

module Up_Counter(clk, reset_n, en, eight_bits);

    input clk;
    input reset_n;
    input en;
    
    output eight_bits;
    
     reg[3:0] cycle_count;
   

    

 /////// the logic of incrementing a counter every clk cycle to track the number of cycles remaining to assert the done signal
    always@(posedge clk or negedge reset_n) begin
         if(!reset_n)
            cycle_count <= 0;
        else
            if(en)
                cycle_count <= cycle_count + 1;
            else
                cycle_count <= cycle_count;

        
    end
   

    assign eight_bits = (cycle_count == 4'b1000) ? 1 : 0;  


endmodule


