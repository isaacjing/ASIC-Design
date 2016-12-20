// $Id: $
// File name:   adder_1bit.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Switching back to sensor_s.sv

module adder_1bit
(
	input wire a,
	input wire b,
	input wire carry_in,
	output wire sum,
	output wire carry_out
);

	assign sum = carry_in ^ (a ^ b);
	assign carry_out = ((! carry_in) & b & a ) | (carry_in & ( b | a));
   //assign {carry_out, sum} = carry_in + a + b;
   
   
endmodule
