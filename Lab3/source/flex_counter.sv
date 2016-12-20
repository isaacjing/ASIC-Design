// $Id: $
// File name:   flex_counter.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: flex_counter.sv
module flex_counter
#(
	parameter NUM_CNT_BITS = 4
)
(
	input wire clk,
	input wire n_rst,
	input wire clear,
	input wire count_enable,
	input wire [NUM_CNT_BITS - 1:0] rollover_val,
	output wire [NUM_CNT_BITS - 1:0] count_out,
	output wire rollover_flag
);
  reg [NUM_CNT_BITS - 1:0] OutputCopy;
  reg [NUM_CNT_BITS - 1:0] OutputCopy_nxt;
  reg rollover;
  reg flag;
  reg flag_nxt;
  
  always_ff @ (posedge clk, negedge n_rst)
  begin
    if(n_rst == 1'b0)	//Reset
    begin
      OutputCopy <= '0;
      flag <= 0;
    end
    else		//If not reset
    begin
      OutputCopy <= OutputCopy_nxt;
      flag <= flag_nxt;
    end
  end

  always_comb
  begin
    OutputCopy_nxt = OutputCopy;
    flag_nxt = flag;
    
    //Actual Count
    if (clear == 0 && count_enable == 1'b1 && flag == 0)
    begin
      flag_nxt = 0;
      OutputCopy_nxt = OutputCopy + 1;
      if (OutputCopy_nxt == rollover_val)	//if reaches rollover next
      begin
	flag_nxt = 1;
      end
    end
    else if(clear == 1)
    begin
	OutputCopy_nxt = '0;
    end
    
    if (flag == 1)				//if current at rollover
      begin
	OutputCopy_nxt = 1;
	flag_nxt = 0;
    end
  end

assign count_out = OutputCopy;
assign rollover_flag = flag;
	  
endmodule
