// $Id: $
// File name:   sync.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: sync.sv
module sync
(
	input clk,
	input n_rst,
	input async_in,
	output reg sync_out
);
  
  reg temp = 0;
  
  always @ (posedge clk, negedge n_rst)
  begin //[: sync]
    if(n_rst == 1'b0)
    begin
      temp <= 1'b0;
      sync_out <= 1'b0;
    end
    else
    begin
      temp <= async_in;
      sync_out <= temp;			//Is here correct?
    end
  end
	
	  
endmodule

/*
Sync Results:
Mapped Results:
Total Score: 2.00/2.00
Score breakdown by test case:
 Results for all test cases not completelly satisfied:


Tb_Sync Results:
Source Results:
 Total Score: 1.5000/2.0000
  All missed/failed test cases will now be reported below:
  Basic Case 4: Setup violation with value of '1' not exercised by test bench
  Basic Case 5: Hold violation with value of '0' not exercised by test bench

*/