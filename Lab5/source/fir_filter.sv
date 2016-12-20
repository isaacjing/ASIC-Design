// $Id: $
// File name:   fir_filter.sv
// Created:     9/20/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Main file for fir_filter design

module fir_filter
(
	input clk,
	input n_reset,
	input [15:0] sample_data,
	input [15:0] fir_coefficient,
	input load_coeff,
	input data_ready,
	output wire one_k_samples,
	output wire modwait,
	output wire [15:0] fir_out,
	output wire err
);
	reg [2:0] Operation;
	reg [3:0] Src1;
	reg [3:0] Src2;
	reg [3:0] Dest;
	reg Overflow;
	reg Cnt_up;
	wire DataReady;
	wire LoadCoeffReady;
	reg Clear;
	reg [16:0] Output;

	datapath Registers (.clk(clk), .n_reset(n_reset), .op(Operation), .src1(Src1), .src2(Src2), .dest(Dest), .ext_data1(sample_data), .ext_data2(fir_coefficient), .outreg_data(Output), .overflow(Overflow));
	controller Controller (.clk(clk), .n_reset(n_reset), .dr(DataReady), .lc(LoadCoeffReady), .overflow(Overflow), .cnt_up(Cnt_up), .clear(Clear), .modwait(modwait), .op(Operation), .src1(Src1), .src2(Src2), .dest(Dest), .err(err));
	counter Counter (.clk(clk), .n_reset(n_reset), .cnt_up(Cnt_up), .clear(Clear), .one_k_samples(one_k_samples));
	sync DataReadySync (.clk(clk), .n_rst(n_reset), .async_in(data_ready), .sync_out(DataReady));
	sync LoadCoeffSync (.clk(clk), .n_rst(n_reset), .async_in(load_coeff), .sync_out(LoadCoeffReady));
	magnitude Magnitude (.in(Output), .out(fir_out));
	
endmodule
