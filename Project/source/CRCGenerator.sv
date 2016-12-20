
// File name:   CRCGenerator.sv
// Created:     11/24/2015

// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: CRC generator, which generates both CRC16 and CRC5 based on received messages.
// Reference: https://ghsi.de/CRC/index.php?Polynom=11000000000000101&Message=FFed
module CRCGenerator
(
 input wire D_plus_sync,
 input wire shift_enable,
 input wire enable_CRC5,
 input wire enable_CRC16, 
 input wire n_rst,
 input wire CLEAR,
 input wire clk,
 output reg [4:0] CRC5,
 output reg [15:0] CRC16
);
wire inv1;
wire inv2;
assign inv1 = D_plus_sync ^ CRC5[4]; 
assign inv2 = D_plus_sync ^ CRC16[15]; 

      always @(posedge clk, negedge n_rst) begin
      if (!n_rst)
         CRC5 <= '0;               
      else if (CLEAR)
	 CRC5 <= '0;
	else begin
	if(enable_CRC5 && shift_enable) begin
	begin
    		CRC5[0] <= inv1;
		CRC5[1] <= CRC5[0];
		CRC5[2] <= CRC5[1];
		CRC5[3] <= CRC5[2] ^ inv1;
        	CRC5[4] <= CRC5[3];
        	end
         end
	 else
		CRC5[4:0] <= CRC5[4:0];
      	end
	end



	always @(posedge clk, negedge n_rst) begin
		if (!n_rst)
			CRC16[15:0] <= '0;
		else if(CLEAR)
			CRC16 <= 0;
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
