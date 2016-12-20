// $Id: $
// File name:   inv_NRZI.sv
// Created:     11/7/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: NRZI encoder for USB transmitter part.
//assuming 8 bits at a time- from main/encode RCU
module encode
(
//input wire change_detected,
input wire n_rst,
input wire clk,
input wire freeze,
input wire bit_ready,
input wire bit_ready2,
input wire e_orig,
output wire d_plus_e,
output wire d_minus_e
);

reg FF1;
reg FF1_nxt;
reg FF2;
reg FF2_nxt;

always_ff @(posedge clk, negedge n_rst)  begin
	if (n_rst == 0) begin
		FF1 <= 1;
		FF2 <= 1;
	end
	else if(freeze == 1) begin
		FF1 <= 1;
		FF2 <= 1;
	end
	else
	begin
		FF1 <= FF1_nxt;
		FF2 <= FF2_nxt;
	end
end

always_comb begin
	FF1_nxt = FF1;
	FF2_nxt = FF2;		//Added on 12/11/2015
	if (bit_ready||bit_ready2) begin
		FF2_nxt = e_orig;
	end

	if(FF2 == 1 & (bit_ready||bit_ready2)) begin
		FF1_nxt = FF1;
	end
	else if (bit_ready||bit_ready2) begin
		FF1_nxt = !FF1;
	end
end

assign d_plus_e = FF1;
assign d_minus_e = !FF1;

endmodule
