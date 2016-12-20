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
    always @ (a, b)
	begin
	assert ((a[i] == 1'b1 || a[i] == 1'b0) && (b[i] == 1'b1 || b[i] == 1'b0))
	else
	  $error ("Input for %d -th bit adder is not correct. Data for this bit: a: %d, b: %d", i, a[i], b[i]);
    end
   end
 
	
  for (i = 0; i <= BIT_WIDTH - 1; i = i + 1)
    begin
    
    adder_1bit MyOwnAdder (.a(a[i]), .b(b[i]), .carry_in(carrys[i]), .sum(sum[i]), .carry_out(carrys[i+1]));
    end
  endgenerate
    assign overflow = carrys[BIT_WIDTH];
  
   
endmodule