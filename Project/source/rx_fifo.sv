// $Id: $
// File name:   rx_fifo.sv
// Created:     10/7/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Receive FIFO Block .

module rx_fifo(
	       input wire r_clk,
	       input wire w_clk,
	       input wire n_rst,
	       input wire r_enable,
	       input wire w_enable,
	       input wire [7:0] w_data,
	       output wire [7:0] r_data,
	       output wire empty,
	       output wire full
	       );


  fifo A1(.r_clk(r_clk), .w_clk(w_clk), .n_rst(n_rst), .r_enable(r_enable), .w_enable(w_enable), .w_data(w_data), .r_data(r_data), .empty(empty), .full(full));
 	

endmodule
 
