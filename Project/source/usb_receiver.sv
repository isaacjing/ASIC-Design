// $Id: $
// File name:   usb_receiver.sv
// Created:     10/20/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Top-level file for usb receiver blocks.
//
//

module usb_receiver(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	input wire d_minus,
	input wire r_enable,
	input wire [15:0] CRC16,
	input wire [4:0] CRC5,
	input wire [2:0] Decode_Instruction,
	output reg [7:0] rcv_data,
	output wire empty,
	output wire full,
	output wire rcving,
	output wire r_error,
	output reg w_enable_d,
	output wire [3:0] d_status,
	output reg enable_CRC5,
	output reg enable_CRC16,
	output reg shift_enable1,
	output wire D_orig,
	output reg ClearCRC,
	input wire Restart
);
	reg shift_enable;
	reg eop;
	reg d_orig;
	reg d_edge;
	reg byte_received;
	reg d_plus1;
	reg d_minus1;

	assign D_orig = d_orig;
 
	sync1 A8(.clk(clk), .n_rst(n_rst), .async_in(d_plus), .sync_out(d_plus1));
	
	sync A9(.clk(clk), .n_rst(n_rst), .async_in(d_minus), .sync_out(d_minus1));

	decode A1(.clk(clk), .n_rst(n_rst), .d_plus(d_plus1), .shift_enable(shift_enable), .eop(eop), .d_orig(d_orig), .rcving(rcving));

	edge_detect A2(.clk(clk), .n_rst(n_rst), .d_plus(d_plus1), .d_edge(d_edge));

	timer A3(.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .rcving(rcving), .shift_enable(shift_enable), .byte_received(byte_received), .shift_enable1(shift_enable1));

	shift_register A4(.clk(clk), .n_rst(n_rst), .shift_enable(shift_enable1), .d_orig(d_orig), .rcv_data(rcv_data));


	eop_detect A6(.d_plus(d_plus1), .d_minus(d_minus1), .eop(eop));

	rcu A7(.clk(clk), .n_rst(n_rst), .d_edge(d_edge), .eop(eop), .shift_enable(shift_enable), .rcv_data(rcv_data), .byte_received(byte_received), .rcving(rcving), .w_enable(w_enable_d), .r_error(r_error), .d_status(d_status), .enable_CRC5(enable_CRC5), .enable_CRC16(enable_CRC16), .ClearCRC(ClearCRC), .CRC5(CRC5), .CRC16(CRC16), .Decode_Instruction(Decode_Instruction), .Restart(Restart));
 
       DecodeBTS A10(.clk(clk), .n_rst(n_rst), .D_Orig(d_orig), .shift_enable(shift_enable), .DecodeSREnable(shift_enable1));
   
endmodule // usb_receiver
