// $Id: $
// File name:   sensor_s.sv
// Created:     8/30/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Sensor error detector logic

//LOGIC: S0 | S1 & S2 | S3 & S1

module sensor_d(
   input wire [3:0] sensors,
   output wire error
		);
   
   
   assign error = sensors[0] | sensors[1] & sensors[2] | sensors[3] & sensors[1];
   
   
   
endmodule // sensor_d
