// $Id: $
// File name:   usb_receiver.sv
// Created:     10/20/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Top-level file for usb receiver test bench only
//
//

module tb_usb_receiver_lab6(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	input wire d_minus,
	input wire r_enable,
	output wire [7:0] r_data,
	output wire empty,
	output wire full,
	output wire rcving,
	output wire r_error
);
	reg shift_enable;
	reg eop;
	reg d_orig;
	reg d_edge;
	reg byte_received;
	reg [7:0] rcv_data;
	reg w_enable;
	reg d_plus1;
	reg d_minus1;
   reg 	    shift_enable1;
	//reg [7:0] w_data;
 
	tb_sync1 A8(.clk(clk), .n_rst(n_rst), .async_in(d_plus), .sync_out(d_plus1));
	
	tb_sync A9(.clk(clk), .n_rst(n_rst), .async_in(d_minus), .sync_out(d_minus1));

	tb_decode A1(.clk(clk), .n_rst(n_rst), .d_plus(d_plus1), .shift_enable(shift_enable), .eop(eop), .d_orig(d_orig));

	tb_edge_detect A2(.clk(clk), .n_rst(n_rst), .d_plus(d_plus1), .d_edge(d_edge));

	tb_timer A3(.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .rcving(rcving), .shift_enable(shift_enable), .byte_received(byte_received), .shift_enable1(shift_enable1));

	tb_shift_register A4(.clk(clk), .n_rst(n_rst), .shift_enable(shift_enable1), .d_orig(d_orig), .rcv_data(rcv_data));

	tb_rx_fifo A5(.clk(clk), .n_rst(n_rst), .r_enable(r_enable), .w_enable(w_enable), .w_data(rcv_data), .r_data(r_data), .empty(empty), .full(full));

	tb_eop_detect A6(.d_plus(d_plus1), .d_minus(d_minus1), .eop(eop));

	tb_rcu_lab6 A7(.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .eop(eop), .shift_enable(shift_enable), .rcv_data(rcv_data), .byte_received(byte_received), .rcving(rcving), .w_enable(w_enable), .r_error(r_error));
	
	tb_DecodeBTS A10(.clk(clk), .n_rst(n_rst), .D_Orig(d_orig), .shift_enable(shift_enable), .DecodeSREnable(shift_enable1));
   
endmodule // usb_receiver
