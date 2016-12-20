// $Id: $
// File name:   sensor_s.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Switching back to sensor_s.sv
module sensor_b
(
	input wire [3:0] sensors,
	output reg error
);
	
   always_comb
   begin
      if (sensors[0] == 1'b1) 
	error = 1;
      else
	if (sensors[1] == 1'b1)
	  if (sensors[2] == 1'b1 | sensors[3] == 1'b1)
	    error = 1;
	  else
	    error = 0;
	else
	  error = 0;  
   end
endmodule
