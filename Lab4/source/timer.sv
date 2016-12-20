// $Id: $
// File name:   timer.sv
// Created:     9/20/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Timer Controller

module timer
(
	input clk,
	input n_rst,
	input enable_timer,
	output wire shift_strobe,
	output wire packet_done
);
	reg Rollover1;
	reg Clear2;
	reg Clear2_nxt;
	reg Clear1;
	reg Clear1_nxt;
	reg Enable_nxt;
	reg Enable;
	wire [3:0] Count1;
	wire [3:0] Count2;
	logic Reset;
	
	flex_counter Counting10 (.clk(clk), .n_rst(n_rst), .count_enable(enable_timer), .rollover_val(4'b1001), .clear(packet_done), .rollover_flag(Rollover1), .count_out(Count1));
	flex_counter Counting9 (.clk(clk), .n_rst(n_rst), .count_enable(Rollover1), .rollover_val(4'b1001), .clear(packet_done), .rollover_flag(packet_done), .count_out(Count2));
	assign shift_strobe = Rollover1;
endmodule
