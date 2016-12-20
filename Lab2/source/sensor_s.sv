// $Id: $
// File name:   sensor_s.sv
// Created:     9/1/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Switching back to sensor_s.sv

module sensor_s
(
	input wire [3:0] sensors,
	output wire error
);
	reg int_and;
        reg int_and2;
   
	reg int_or;
        reg int_or2;

   
        and A (int_and, sensors[1], sensors[2]);
        and B (int_and2, sensors[3], sensors[1]);
           
	or C (int_or, int_and, sensors[0]);
        or D (error, int_or, int_and2);
   
endmodule
