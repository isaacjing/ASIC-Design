// $Id: $
// File name:   timer.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: timer.sv, output shift_enable and byte_received signal
module timer
(
	input wire clk,
	input wire n_rst,
	input wire d_edge,
	input wire rcving,
	output wire shift_enable,
	output wire byte_received
);
  
reg [3:0] BitOut;

  flex_counter CountingBit(.clk(clk), .n_rst(n_rst), .clear((d_edge | (~rcving))), .count_enable(rcving), .rollover_val(4'd7), .count_out(BitOut));
  flex_counter CountingByte(.clk(clk), .n_rst(n_rst), .count_enable(shift_enable), .clear(~rcving), .rollover_val(4'd8), .rollover_flag(byte_received));

  assign shift_enable = (BitOut == 4'd3);

endmodule
