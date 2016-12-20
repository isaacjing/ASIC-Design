// $Id: $
// File name:   flex_counter.sv
// Created:     9/22/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Flexible and Scaleable flex counter with controlled rollover
// 
module flex_counter
#(
  NUM_CNT_BITS = 4
  )
   (
    input wire clk,
    input wire n_rst,
    input wire clear,
    input wire count_enable,
    input wire [(NUM_CNT_BITS-1):0] rollover_val,
    output wire [(NUM_CNT_BITS-1):0] count_out,
    output reg rollover_flag
    );

   reg [(NUM_CNT_BITS-1):0] c_state;
   reg 			    c_state_flag;
   
   reg [(NUM_CNT_BITS-1):0] n_state;
   reg 			    n_state_flag;

   always_ff @ (posedge clk, negedge n_rst)
     begin
	if(n_rst == 0)begin
	   c_state <= 1'b0;
	   c_state_flag <= 1'b0;
	end
	else begin
	   c_state <= n_state;
	   c_state_flag <= n_state_flag;
	end
	
     end
   
  always_comb begin
     n_state = c_state;
     n_state_flag = '0;
     
     if(clear == 1) begin
	n_state = '0;
	n_state_flag = '0;
     end
     else begin
	if((count_enable == 1)) begin
	   n_state = c_state +1;
	   n_state_flag = '0;
	   if(n_state == rollover_val) begin
	      n_state_flag = '1;
	   end
	   if(n_state == (rollover_val+1)) begin
	      n_state = 1;
	   end
	   if((c_state_flag == 1)) begin
		n_state = 0;
		n_state_flag = 0;
           end
	end
     end // else: !if(clear == 1)
  end // always_comb begin

   assign count_out = c_state;
   assign rollover_flag = c_state_flag;

endmodule // flex_counter

	
	  
	  
	
       
	  
   
		    
