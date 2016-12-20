// $Id: $
// File name:   EncodeBTS.sv
// Created:     11/24/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: encodeBTS, which is a small state machine that counts how many 1s in original data. It will pause shift register once there are 6 1s, and add an extra zero.
module EncodeBTS(
input wire clk,
input wire n_rst,
input wire E_original,
input wire bit_ready,
output logic E_orig,
output logic pause,
output logic bit_ready2
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
	E_orig=E_original;
	pause=1'b0;
	bit_ready2=1'b0;
	next_state = current_state;
	case(current_state)
	IDLE:begin
		E_orig=E_original;
		pause=1'b0;
		if(bit_ready==1'b1&&E_original==1'b1)//1
		begin
			next_state=S1;
		end
		else
		begin
			next_state=IDLE;
		end
	end



	S1:begin
		E_orig=E_original;
		pause=1'b0;
		if(bit_ready==1'b1&&E_original==1'b1)//11
		begin
			next_state=S2;
		end
		else if(bit_ready==1'b1&&E_original==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S1;
		end

	end

	S2:begin
		E_orig=E_original;
		pause=1'b0;
		if(bit_ready==1'b1&&E_original==1'b1)//111
		begin
			next_state=S3;
		end
		else if(bit_ready==1'b1&&E_original==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S2;
		end

	end

	S3:begin
		E_orig=E_original;
		pause=1'b0;
		if(bit_ready==1'b1&&E_original==1'b1)//1111
		begin
			next_state=S4;
		end
		else if(bit_ready==1'b1&&E_original==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S3;
		end

	end


	S4:begin
		E_orig=E_original;
		pause=1'b0;
		if(bit_ready==1'b1&&E_original==1'b1)//11111
		begin
			next_state=S5;
		end
		else if(bit_ready==1'b1&&E_original==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S4;
		end

	end




	S5:begin
		E_orig=E_original;
		pause=1'b0;
		if(bit_ready==1'b1&&E_original==1'b1)//111111
		begin
			next_state=S6;
		end
		else if(bit_ready==1'b1&&E_original==1'b0)
		begin
			next_state=IDLE;
		end
		else
		begin
			next_state=S5;
		end

	end


	S6:begin
		E_orig=1'b0;
		pause=1'b1;
		next_state=S7;

	end
	
	S7:begin
		E_orig=1'b0;
		pause=1'b1;
		next_state=S8;

	end

	S8:begin
		E_orig=1'b0;
		pause=1'b1;
		bit_ready2=1'b0;
		next_state=S9;

	end

	S9:begin
		E_orig=1'b0;
		pause=1'b1;
		bit_ready2=1'b1;
		next_state=S10;

	end

	S10:begin
		E_orig=1'b0;
		pause=1'b1;
		next_state=S11;
		bit_ready2=1'b0;

	end


	S11:begin
		E_orig=1'b0;
		pause=1'b1;
		bit_ready2=1'b0;
		next_state=S12;
		
	end


	S12:begin
		E_orig=1'b0;
		pause=1'b1;
		next_state=S13;
		bit_ready2=1'b0;

	end


	S13:begin
		E_orig=1'b0;
		pause=1'b1;
		bit_ready2=1'b0;
		next_state=IDLE;

	end


	endcase

end



endmodule

