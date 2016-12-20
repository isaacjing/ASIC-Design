// $Id: $
// File name:   timer.sv
// Created:     10/20/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Timer Block for Lab 6, for test bench use
// 
module tb_timer(
	input wire clk,
	input wire n_rst,
	input wire d_edge,
	input wire rcving,
	input wire shift_enable1,
	output reg shift_enable,
	output wire byte_received
);
   //reg [3:0] 	    count1;
	reg [3:0] count2;
	reg count_10_8;
   
	// Counter 1 - Count number of bits received
	// Number of bits changes in rollover_val
	tb_flex_counter #(4) count_byte(
		.clk(clk), 
		.n_rst(n_rst), 
		.clear(!rcving), 
		.count_enable(shift_enable & shift_enable1), //rcving & count_10_8 //shift_enable
		.rollover_val(4'b1000), 
		.count_out(), 
		.rollover_flag(byte_received)
		);

	// Counter 2 - Counter for sampling
	tb_flex_counter #(4) count_sample(
		.clk(clk), 
		.n_rst(n_rst), 
		.clear(d_edge), 
		.count_enable(rcving),
		.rollover_val(4'b0111), 
		.count_out(count2), 
		.rollover_flag(count_10_8)
		);

//	always_ff @(posedge clk, negedge n_rst) 
//	begin
//		if(n_rst == 1'b0)
//		begin
//			shift_enable <= 0;
//		end 
//		else 
//		begin
	assign shift_enable = (rcving && (count2 == 3));
//	assign shift_enable = count_10_8;
//		end
//	end

endmodule // timer
