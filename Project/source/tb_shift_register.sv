// $Id: $
// File name:   shift_register.sv
// Created:     10/20/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Shift register block for test bench

module tb_shift_register(
		      input wire clk,
		      input wire n_rst,
		      input wire shift_enable,
		      input wire d_orig,
		      output wire [7:0] rcv_data
		      );
   
	tb_flex_stp_sr 
	#(
		.NUM_BITS(8),
		.SHIFT_MSB(0)
		)
	CORE(
		.clk(clk),
		.n_rst(n_rst),
		.serial_in(d_orig),
		.shift_enable(shift_enable),
		.parallel_out(rcv_data)
	);

endmodule // shift_register
