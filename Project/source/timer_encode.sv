// $Id: $
// File name:   timer_encode.sv
// Created:     11/7/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: encode timer, for transmitter block
module timer_encode
(
	input wire clk,
	input wire n_rst,
	input wire sending,
	input wire clear,
	input wire pause,
	
	output wire bit_ready,
	output wire byte_done,
	output wire PTSShift
);
reg [3:0] cout_out1;
reg [3:0] cout_out2;
reg rollover_flag1;
reg rollover_flag2;
//reg dplus;
//reg dminus;
//reg clr = !clear;

flex_counter_0 #(4) count1_7
(.clk(clk), .n_rst(n_rst), .clear(clear),
 .count_enable(sending&&!pause), .rollover_val(4'd7),
 .count_out(cout_out1), .rollover_flag(rollover_flag1));//bit wise

flex_counter_0 #(4) count2_7
(.clk(clk), .n_rst(n_rst), .clear(clear),
 .count_enable(PTSShift&&!pause), .rollover_val(4'd8),
 .count_out(cout_out2), .rollover_flag(rollover_flag2)); //byte wise


assign bit_ready=(cout_out1 == 4'd1);	//This may need to be changed
assign PTSShift = (cout_out1 == 4'd1);

assign byte_done=rollover_flag2;




/*always_comb
begin
	cout_out1 = cout_out1 - 1;//1-16=> 0-15
	cout_out2 = cout_out2 - 1;//1-16=> 0-15
	
end *///Why are you doing this ????
endmodule
