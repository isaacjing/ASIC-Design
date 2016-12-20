// $Id: $
// File name:   DecodeBTS.sv
// Created:     11/24/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: decode BTS, which handles bit stuffing for decoding, for testing only
module tb_DecodeBTS(
input wire clk,
input wire n_rst,
input wire D_Orig,
input wire shift_enable,
output reg DecodeSREnable


);

typedef enum logic[3:0]{IDLE, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13 } state;
state current_state;
state next_state;


always_ff @(posedge clk, negedge n_rst)
begin
	if(n_rst==1'b0)
	begin
		current_state<=IDLE;
	end
	else begin
		current_state<=next_state;
	end
end




always_comb
begin
	DecodeSREnable=shift_enable;
	

	case(current_state)
	IDLE:begin
		DecodeSREnable=shift_enable;
		if(shift_enable==1'b1&&D_Orig==1'b1)//1
		begin
			next_state=S1;
		end
		else
		begin
			next_state=IDLE;
		end
	end



	S1:begin
		DecodeSREnable=shift_enable;
		if(shift_enable==1'b1&&D_Orig==1'b1)//11
		begin
			next_state=S2;
		end
		else if(shift_enable==1'b1&&D_Orig==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S1;
		end

	end

	S2:begin
		DecodeSREnable=shift_enable;
		if(shift_enable==1'b1&&D_Orig==1'b1)//111
		begin
			next_state=S3;
		end
		else if(shift_enable==1'b1&&D_Orig==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S2;
		end

	end

	S3:begin
		DecodeSREnable=shift_enable;
		if(shift_enable==1'b1&&D_Orig==1'b1)//1111
		begin
			next_state=S4;
		end
		else if(shift_enable==1'b1&&D_Orig==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S3;
		end

	end


	S4:begin
		DecodeSREnable=shift_enable;
		if(shift_enable==1'b1&&D_Orig==1'b1)//11111
		begin
			next_state=S5;
		end
		else if(shift_enable==1'b1&&D_Orig==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S4;
		end

	end




	S5:begin
		DecodeSREnable=shift_enable;
		if(shift_enable==1'b1&&D_Orig==1'b1)//111111
		begin
			next_state=S6;
		end
		else if(shift_enable==1'b1&&D_Orig==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S5;
		end

	end


	S6:begin
		DecodeSREnable=1'b0;
		next_state=S7;

	end


	S7:begin
		DecodeSREnable=1'b0;
		next_state=S8;

	end

	S8:begin
		DecodeSREnable=1'b0;
		next_state=S9;

	end

	S9:begin
		DecodeSREnable=1'b0;
		next_state=S10;

	end

	S10:begin
		DecodeSREnable=1'b0;
		next_state=S11;
		

	end


	S11:begin
		DecodeSREnable=1'b0;
		next_state=S12;
		
	end


	S12:begin
		DecodeSREnable=1'b0;
		next_state=S13;
		

	end


	S13:begin
		DecodeSREnable=1'b0;
		next_state=IDLE;

	end


	endcase
end
endmodule

