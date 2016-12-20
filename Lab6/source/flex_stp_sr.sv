// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: flex_stp_sr.sv
module flex_stp_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1
 )
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire serial_in,
	output wire [NUM_BITS - 1:0] parallel_out
);
  reg [NUM_BITS - 1:0] temp;
  reg [NUM_BITS - 1:0] temp_nxt;
  
  always_ff @ (posedge clk, negedge n_rst)
  begin
    if(n_rst == 1'b0)
    begin      
      temp <= 2**NUM_BITS - 1;
    end
    else
    begin
      temp <= temp_nxt;
    end
  end

always_comb
begin
      temp_nxt = temp; //DEFAULT STATE
      if (SHIFT_MSB == 0 && shift_enable == 1'b1)
      begin
	 temp_nxt = temp >> 1;
	 temp_nxt[NUM_BITS - 1] = serial_in;

      end
      
      if (SHIFT_MSB == 1 && shift_enable == 1'b1)
      begin
	  temp_nxt = temp << 1;
	  temp_nxt[0] = serial_in;
      end
end
	assign parallel_out[NUM_BITS - 1:0] = temp[NUM_BITS - 1:0];
	  
endmodule