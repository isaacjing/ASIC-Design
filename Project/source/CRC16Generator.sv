// $Id: $
// File name:   CRC16Generator.sv
// Created:     11/24/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: CRC16 16 Generator for output data onto USB bus
// Reference: https://ghsi.de/CRC/
module CRC16Generator
(
 input wire D_Plus_sync,
 input wire shift_enable,
 input wire enable_CRC16, 
 input wire CLEAR,
 output reg [15:0] CRC16,
 input wire n_rst,
 input wire clk
);	
	
wire inv2;
assign inv2 = D_Plus_sync ^ CRC16[15]; 
   
	always @(posedge clk, negedge n_rst) begin
		if (!n_rst)
			CRC16[15:0] <= '0;
		else if(CLEAR)
			CRC16 <= '0;
		else begin				
			if(enable_CRC16 && shift_enable) begin
				CRC16[0] <= inv2;
				CRC16[1] <= CRC16[0];
				CRC16[2] <= CRC16[1] ^ inv2;
				CRC16[3] <= CRC16[2];
				CRC16[4] <= CRC16[3];
				CRC16[5] <= CRC16[4];
				CRC16[6] <= CRC16[5];
				CRC16[7] <= CRC16[6];
				CRC16[8] <= CRC16[7];
				CRC16[9] <= CRC16[8];
				CRC16[10] <= CRC16[9];
				CRC16[11] <= CRC16[10];
				CRC16[12] <= CRC16[11];
				CRC16[13] <= CRC16[12];
				CRC16[14] <= CRC16[13];
				CRC16[15] <= CRC16[14] ^ inv2;  
			end
			else
				CRC16[15:0] <= CRC16[15:0];
		end
	end
   
endmodule
