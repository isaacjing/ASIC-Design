// $Id: $
// File name:   edge_detect.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: edge_detect.sv, detect changinn of staae of input d_plus
module decode
(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	input shift_enable,
	input eop,
	output wire d_orig
);
  reg FF1;
  reg FF1_nxt;
  reg FF2_nxt;
  reg FF2;
  reg Output;
  
  always_ff @ (posedge clk, negedge n_rst)
  begin
    if(n_rst == 1'b0)	//Reset
    begin
      FF1 <= 1;
      FF2 <= 1;
    end
    else		//If not reset
    begin
      FF1 <= FF1_nxt;
      FF2 <= FF2_nxt;
    end
  end

  always_comb
  begin
    FF1_nxt = FF1;
    FF2_nxt = FF2;
    if (shift_enable) begin
	FF2_nxt = d_plus;
    end
    if (d_plus == FF2_nxt)
    begin
      FF1_nxt = 1;
    end
    else
    begin
      FF1_nxt = 0;
    end
    if (eop & shift_enable) begin
	FF1_nxt = 1;
	FF2_nxt = 1;
    end
    /*if (eop == 1 & shift_enable == 0) begin
	FF1_nxt = d_plus;
    end*/
  end

assign d_orig = FF1;	  
endmodule
