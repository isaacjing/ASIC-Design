// $Id: $
// File name:   sr_9bit.sv
// Created:     9/20/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: 9 bit shift register (s to p) for uart
module sr_9bit
(
	input wire clk,
	input wire n_rst,
	input wire shift_strobe,
	input serial_in,
	output wire [7:0] packet_data,
	output wire stop_bit
);
	wire [8:0] OutputData;

	assign packet_data[7:0] = OutputData[7:0];
	assign stop_bit = OutputData[8];

	flex_stp_sr #(9, 0) Shifting (.clk(clk), .n_rst(n_rst), .shift_enable(shift_strobe), .serial_in(serial_in), .parallel_out(OutputData));
	
endmodule
