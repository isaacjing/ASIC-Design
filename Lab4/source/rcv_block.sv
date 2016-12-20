// $Id: $
// File name:   rcv_block.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: rcv_block.sv

`timescale 1ns / 100ps

module rcv_block(
	input clk,
	input n_rst,
	input data_read,
	input serial_in,
	output logic data_ready,
	output logic overrun_error,
	output logic framing_error,
	output wire [7:0] rx_data
);
reg Serial;
reg Serial_nxt;
reg Start;
reg Finish;
reg Strobe;
wire [7:0] Data;
reg stop_bit;
reg SBCClear;
reg SBCEnable;
reg FramingError;
reg LoadBuffer;
reg EnableTimer;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst == 0) begin
		Serial <= 1;
	end
	else begin
		Serial <= Serial_nxt;
	end
end

always_comb
begin
	Serial_nxt = serial_in;
end

start_bit_det StartBitDetect (.clk(clk), .n_rst(n_rst), .serial_in(Serial), .start_bit_detected(Start));

timer Timer (.clk(clk), .n_rst(n_rst), .enable_timer(EnableTimer), .shift_strobe(Strobe), .packet_done(Finish));

sr_9bit ShiftRegister (.clk(clk), .n_rst(n_rst), .shift_strobe(Strobe), .serial_in(Serial), .packet_data(Data), .stop_bit(stop_bit));

stop_bit_chk StopBitCheck (.clk(clk), .n_rst(n_rst), .sbc_clear(SBCClear), .sbc_enable(SBCEnable), .stop_bit(stop_bit), .framing_error(framing_error));

rcu ReceiverControlUnit (.clk(clk), .n_rst(n_rst), .start_bit_detected(Start), .packet_done(Finish), .framing_error(framing_error), .sbc_clear(SBCClear), .sbc_enable(SBCEnable), .load_buffer(LoadBuffer), .enable_timer(EnableTimer));

rx_data_buff DataBuf (.clk(clk), .n_rst(n_rst), .load_buffer(LoadBuffer), .packet_data(Data), .data_ready(data_ready), .overrun_error(overrun_error), .rx_data(rx_data), .data_read(data_read));
endmodule
