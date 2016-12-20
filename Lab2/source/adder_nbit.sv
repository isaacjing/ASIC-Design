// $Id: $
// File name:   adder_nbit.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: n bit adder

module adder_nbit
#(
	parameter BIT_WIDTH = 4
 )
 (
	input wire [BIT_WIDTH - 1:0] a,
	input wire [BIT_WIDTH - 1:0] b,
	input wire carry_in,
	output wire [BIT_WIDTH - 1:0] sum,
	output wire overflow
);

 wire [BIT_WIDTH:0] carrys;
 genvar i;
 assign carrys[0] = carry_in;
 
 generate
  for (i = 0; i <= BIT_WIDTH - 1; i = i + 1)
    begin
    
    adder_1bit MyOwnAdder (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), .carry_out(carrys[i+1]));
    end
  endgenerate
    assign overflow = carrys[BIT_WIDTH];
  
   
endmodule

/*
	Adder_Nbit Results:
Source Results:
Total Score: 3.00/3.00
Score breakdown by test case:
 Results for all test cases not completelly satisfied:

Mapped Results:
Total Score: 3.00/3.00
Score breakdown by test case:
 Results for all test cases not completelly satisfied:


Tb_Adder_8Bit Results:
Source Results:
 Total Score: 0.5000/1.0000
  All missed/failed test cases will now be reported below:


*/
