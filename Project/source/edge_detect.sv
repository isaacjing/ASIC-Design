// $Id: $
// File name:   edge_detect.sv
// Created:     10/8/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Edge detector block.

module edge_detect(
		   input wire clk,
		   input wire d_plus,
		   input wire n_rst,
		   output reg d_edge
		   );
   reg 			       temp;
   reg 			       temp1;
   reg 			       temp_1;
   reg 			       temp1_1;
   reg 			       out;
   

always_ff @ (posedge clk, negedge n_rst) begin
   if(n_rst == 1'b0) begin
      temp <= d_plus;
      temp1 <= d_plus;
   end
   else begin
      temp <= temp_1;
      temp1 <= temp1_1;
   end
end // always_ff @ (posedge clk, negedge n_rst)

always_comb begin
   temp_1 = d_plus;
   temp1_1 = temp;

   if(( temp != temp1)) begin
      d_edge = 1'b1;
   end
   else begin
      d_edge = 1'b0;
   end
end

//   assign d_edge = out;   
endmodule // edge_detect
