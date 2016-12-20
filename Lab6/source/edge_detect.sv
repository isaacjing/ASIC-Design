// $Id: $
// File name:   edge_detect.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: edge_detect.sv, detect changinn of staae of input d_plus
module edge_detect
(
	input wire clk,
	input wire n_rst,
	input wire d_plus,
	output wire d_edge
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
      FF1 <= d_plus;
      FF2 <= d_plus;
    end
    else		//If not reset
    begin
      FF1 <= FF1_nxt;
      FF2 <= FF2_nxt;
    end
  end

  always_comb
  begin
    FF1_nxt = d_plus;
    FF2_nxt = FF1;
	
    if (FF1 != FF2)
    begin
      Output = 1;
    end
    else
    begin
      Output = 0;
    end
  end

assign d_edge = Output;	  
endmodule
