// $Id: $
// File name:   adder_1bit.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Switching back to sensor_s.sv
`timescale 1ns / 100ps
module adder_1bit
(
	input wire a,
	input wire b,
	input wire carry_in,
	output wire sum,
	output wire carry_out
);
	always @ (a, b)
	begin
	assert ( a == 1'b1 || a == 1'b0 || b == 1'b1 || b == 1'b0 )
	else
	  $error ("Input for 1 bit adder is not correct. a: %d, b: %d", a, b);
	end
	
	assign sum = carry_in ^ (a ^ b);
	assign carry_out = ((! carry_in) & b & a ) | (carry_in & ( b | a));
   //assign {carry_out, sum} = carry_in + a + b;
	
	
	always @ (a, b, carry_in)
	begin
	#(5)
	assert ( {carry_out, sum} == a + b + carry_in )
	else
	  $error ("Output for 1 bit adder is not correct. a: %d, b: %d, carry in %d, sum: %d, carry_out: %d", a, b, carry_in, sum, carry_out);
	end
   
endmodule
