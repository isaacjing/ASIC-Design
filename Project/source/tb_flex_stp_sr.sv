// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/20/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: N-bit Serial to Parallel Shift Register Design 
// 

module tb_flex_stp_sr
#(
  parameter NUM_BITS=4,
  parameter SHIFT_MSB=1
)
(
 input wire clk,
 input wire n_rst,
 input wire shift_enable,
 input wire serial_in,
 output reg [(NUM_BITS-1):0] parallel_out
 );

reg [(NUM_BITS-1):0] num;

always_ff @ (posedge clk, negedge n_rst)
  	begin
       	if(n_rst == 1'b0)begin
          	parallel_out <= '1;
        	end
       	else begin
          	parallel_out <= num;
  		end
end

always_comb begin
	if(shift_enable == 1 && SHIFT_MSB == 0) begin 
		   num = {serial_in, parallel_out[(NUM_BITS-1):1]};
		   
			end
        else if(shift_enable == 1 && SHIFT_MSB == 1)begin
		   num = {parallel_out[(NUM_BITS-2):0], serial_in};
		      
		end
	else begin
		num = parallel_out;
		end
	end
endmodule 
/*
module flex_stp_sr
#(
NUM_BITS=4,
SHIFT_MSB=1
)

(
input wire clk,
input wire n_rst,
input wire shift_enable,
input wire serial_in,
output reg [NUM_BITS-1:0]parallel_out
);




reg[(NUM_BITS-1):0] ns;
always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst==0)
	begin
		parallel_out<='1;
	end
	else
	begin
		parallel_out<=ns;
	end
end




always_comb
begin
	//if((shift_enable==1)
		//begin
	if((SHIFT_MSB==1)&&(shift_enable==1))//active high
		begin 
		ns[NUM_BITS-1:1]=parallel_out[NUM_BITS-2:0];
		ns[0]=serial_in;
		end		
	
	else if(SHIFT_MSB==0&&shift_enable==1) begin
	
		ns[NUM_BITS-2:0]=parallel_out[NUM_BITS-1:1];
		ns[NUM_BITS-1]=serial_in;
	end
	else begin
		ns=parallel_out;
	end
end
endmodule
   

		   
*/
