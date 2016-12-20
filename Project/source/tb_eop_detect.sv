// $Id: $
// File name:   eop_detect.sv
// Created:     10/8/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: EOP detect block. for testing only

module tb_eop_detect(
		  input wire d_plus,
		  input wire d_minus,
		  output reg eop
		  );

assign  eop = !d_plus & !d_minus;
   

endmodule // eop_detect
