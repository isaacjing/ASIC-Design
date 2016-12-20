// $Id: $
// File name:   usb_receiver.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Main block for USB 1.0 receiver

module usb_receiver
(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	input wire d_minus,
	input wire r_enable,
	output wire [7:0] r_data,
	output wire empty,
	output reg full,
	output reg rcving,
	output reg r_error
);
	reg d_plus_sync;
	reg d_minus_sync;
	reg d_edge;
	reg d_orig;
	reg eop;
	reg shift_enable;
	reg byte_received;
	reg w_enable;
	reg [7:0] rcv_data;
	
	//Two Synchronizers
	sync DPlusSync(.clk(clk), .n_rst(n_rst), .async_in(d_plus), .sync_out(d_plus_sync));
	sync DMinusSync(.clk(clk), .n_rst(n_rst), .async_in(d_minus), .sync_out(d_minus_sync));
	
	//Edge Detector
	edge_detect EdgeDetector(.clk(clk), .n_rst(n_rst), .d_plus(d_plus_sync), .d_edge(d_edge));
	
	//Timer
	timer Timer(.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .rcving(rcving), .shift_enable(shift_enable), .byte_received(byte_received));
	
	//Decode
	decode Decoder(.clk(clk), .n_rst(n_rst), .d_plus(d_plus_sync), .shift_enable(shift_enable), .eop(eop), .d_orig(d_orig));
	
	//Shift Register
	shift_register ShiftRegister(.clk(clk), .n_rst(n_rst), .shift_enable(shift_enable), .d_orig(d_orig), .rcv_data(rcv_data));
	
	//RCV FIFO
	rx_fifo FIFO(.clk(clk), .n_rst(n_rst), .r_enable(r_enable), .w_enable(w_enable), .w_data(rcv_data), .r_data(r_data), .full(full), .empty(empty));
	
	//EOP Detector
	eop_detect EOPDetector(.d_plus(d_plus_sync), .d_minus(d_minus_sync), .eop(eop));
	
	//RCU
	rcu RCU(.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .eop(eop), .shift_enable(shift_enable), .rcv_data(rcv_data), .byte_received(byte_received), .rcving(rcving), .w_enable(w_enable), .r_error(r_error));
endmodule