// $Id: $
// File name:   adder_4bit.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Switching back to sensor_s.sv

module adder_4bit
(
	input wire [3:0] a,
	input wire [3:0] b,
	input wire carry_in,
	output wire [3:0] sum,
	output wire overflow
);

 wire [4:0] carrys;
 genvar i;
 assign carrys[0] = carry_in;
 
 generate
  for (i = 0; i <= 3; i = i + 1)
    begin
    
    adder_1bit MyOwnAdder (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), .carry_out(carrys[i+1]));
    end
  endgenerate
    assign overflow = carrys[4];
  
   
   
endmodule
