// $Id: $
// File name:   decode.sv
// Created:     10/7/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Decode Block, for testing purpose only.

module tb_decode(
	      input wire clk,
	      input wire n_rst,
	      input wire d_plus,
	      input wire shift_enable,
	      input wire eop,
		input wire rcving,
	      output reg d_orig
	      );
   reg 			  temp;
   reg 			  temp1;
   reg 			  temp_1;
   reg 			  temp1_1;
 			  
   
  always @(posedge clk,negedge n_rst) begin
    if((n_rst == 1'b0)) begin
      temp <= 1'b1;
      temp1 <= 1'b1;
    end
    else if (rcving == 0) begin
		temp <= '1;
		temp1<= '1;
	end
    else begin
       temp <= temp_1;
       
       temp1 <= temp1_1;
       
    end
  end

   always_comb begin
      temp_1 = temp;
      temp1_1 = temp1;
      if((shift_enable == 1'b1)) begin
         temp1_1 = d_plus;
      end
      if((d_plus == temp1_1)) begin
	 temp_1 = 1'b1;
      end
      else begin
         temp_1 = 1'b0;
      end
      if (eop == 1'b1  && shift_enable == 1'b1) begin
	 temp_1 = 1'b1;
	 temp1_1 = 1'b1;
      end
  end // always @ (posedge clk,posedge n_rst,posedge shift_enable,posedge d_plus)

   assign d_orig = temp;
   

endmodule // decode
