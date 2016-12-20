// $Id: $
// File name:   sync.sv
// Created:     9/8/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Sychnronizer Design Specification for testing

module tb_sync
  (
   input wire clk,
   input wire n_rst,
   input wire async_in,
   output reg sync_out
   );
   reg a;
   always_ff @ (posedge clk, negedge n_rst)
     begin
	if(1'b0 == n_rst)
	  begin
	     a <= 1'b0;
	     sync_out <= 1'b0;
	  end
	else
	  begin
	     a <= async_in;
	     sync_out <= a;
	  end
     end // always_ff @ (posedge clk, negedge n_rst)
 
  endmodule
