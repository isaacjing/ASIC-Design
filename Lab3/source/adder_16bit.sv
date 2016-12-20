// $Id: $
// File name:   adder_16bit.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: 16 bit adder

// 337 TA Provided Lab 2 8-bit adder wrapper file template
// This code serves as a template for the 8-bit adder design wrapper file 
// STUDENT: Replace this message and the above header section with an
// appropriate header based on your other code files

module adder_16bit
(
	input wire [15:0] a,
	input wire [15:0] b,
	input wire carry_in,
	output wire [15:0] sum,
	output wire overflow
);
genvar i;
	// STUDENT: Fill in the correct port map with parameter override syntax for using your n-bit ripple carry adder design to be an 8-bit ripple carry adder design
  for (i = 0; i <= 15; i = i + 1)
   begin
    always @ (a, b)
	begin
	assert ((a[i] == 1'b1 || a[i] == 1'b0) && (b[i] == 1'b1 || b[i] == 1'b0))
	else
	  $error ("Input for %d -th bit adder is not correct. Value for this bit: a: %d, b: %d", i, a[i], b[i]);
    end
   end
	adder_nbit #(16) Scaleable (.a(a), .b(b), .carry_in(carry_in), .sum(sum), .overflow(overflow));
endmodule
