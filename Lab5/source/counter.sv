// $Id: $
// File name:   counter.sv
// Created:     9/20/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Timer Controller

module counter
(
	input clk,
	input n_reset,
	input clear,
	input cnt_up,
	output wire one_k_samples
);

	wire [9:0] Count1;
	
	flex_counter #10 Counting1000 (.clk(clk), .n_rst(n_reset), .count_enable(cnt_up), .rollover_val(10'd1000), .clear(clear), .rollover_flag(one_k_samples), .count_out(Count1));
endmodule
