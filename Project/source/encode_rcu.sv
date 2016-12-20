// $Id: $
// File name:   encode_rcu.sv
// Created:     11/14/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: encode rcu. The brain of USB transmitter. This is a very big state machine which handles USB data packets.
module encode_rcu(
input wire byte_done,
input wire [3:0] Encode_Instruction,
input wire w_enable,
input wire eop_done,
input wire clk,
input wire n_rst,
input wire bit_ready,
input wire [15:0] CRC,


output reg freeze,
output reg [2:0] Encode_Status,
output reg ACK_Enable,
output reg r_enable_e,
output reg output_selection,
output reg sending,
output reg selection,
output reg [7:0] ack,
output reg load_enable,
output wire clear,
output reg clear_crc,
output reg enable_CRC

);

typedef enum logic[35:0]{IDLE, READY0, READY, READY2, READY3, READY4, START, SHIFT_OUT, WRITE_DONE, DONE, PRE_WRITE_DONE, PRE_WRITE_DONE2,
ACK1, ACK2, ACK3, ACK4, ACKB1, ACKB2, ACKB3, ACKB4, SYNC1, SYNC2, DATA1_1, DATA1_2, CRC_FIFO, DATA1_1_1, SYNC1_1, SYNC2_1, ACKB4_1, ACKB3_1, ACKB2_1, ACKB1_1, ACK4_1, ACK3_1, ACK2_1, ACK1_1, READY3_0, READY3_1, READY4_0, READY4_1, START_0, START_1, SHIFT_OUT_0, SHIFT_OUT_1, SHIFT_OUT_10, READY3_10, READY4_10, START_10, PRE_WRITE_DONE3, PRE_WRITE_DONE2_1, PRE_WRITE_DONE2_2, PRE_WRITE_DONE2_3, PRE_WRITE_DONE2_4, PRE_WRITE_DONE2_5, PRE_WRITE_DONE2_6, PRE_WRITE_DONE2_7, PRE_WRITE_DONE2_8, PRE_WRITE_DONE2_9, PRE_WRITE_DONE4, PAUSE_DONE, PAUSE_WRITE_DONE, PAUSE_DONE2} state;
state current_state;
state next_state;

reg Clear;
reg [2:0] next_Encode_Status;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst==0)
	begin
		current_state<=IDLE;
		Encode_Status <= '0;
		//op<=0;
		//op1<=0;
	end
	else
	begin
		//op <= output_D_plus;
		//op1 <= output_D_minus;
		current_state<=next_state;
		Encode_Status <= next_Encode_Status;
	end
end


always_comb
begin 
	sending = 0;
	selection = 0;
	Clear = 0;
	clear_crc = 0;
	freeze = 0;
	enable_CRC = 0;
	ack = 0;
	ACK_Enable = 0;
	output_selection = 0;
	next_Encode_Status = Encode_Status;
	next_state = current_state;
	r_enable_e = 0;
	load_enable = 0;

	case(current_state)
	IDLE:		//Number 0
		begin
		selection = 0;
		output_selection=0;
		next_Encode_Status = '0;
		Clear = 1;
		freeze = 1;
		/*if(w_enable==0)
		begin
			next_state=IDLE;
		end*/
		if(Encode_Instruction==4'b0110)
		begin
			next_state=ACK1;
		end
		else if(Encode_Instruction==4'b0011)
		begin
			next_state=ACKB1;
		end	

		else if(Encode_Instruction==4'b0100)
		begin
			next_state=SYNC1;
		end
		else if(w_enable == 0)
		begin
			next_state=IDLE;
		end
		else
			next_state = READY0;
		end

	






	READY0:		//Number 1
		begin
		r_enable_e = 0;
		selection = 0;
		output_selection = 0;
		next_state = READY;
		end
	READY:		//Number 2 Load 8-bit parallel data into shift register
		begin
		load_enable = 1;
		r_enable_e = 0;	
		output_selection = 0;
		next_state = READY2;
		end
	READY2:		//Number 3
		begin
		load_enable = 0;
		output_selection = 0;
		next_state = START_0;
		end
	READY3:		//Number 4 Load 8-bit parallel data into shift register
		begin
		load_enable = 1;
		sending=1;
		r_enable_e = 0;	
		output_selection = 0;
		enable_CRC = 1;
		//f(Encode_Instruction==4'b0111)
		//begin
		//	next_state=CRC_FIFO;
		//end
		//else begin
		next_state = READY4;
		//end

		if(w_enable == 0)
			next_state = PRE_WRITE_DONE2_5;
		end
	READY4:		//Number 5
		begin
		load_enable = 0;
		sending=1;
		enable_CRC = 1;
		output_selection = 0;
		//if(Encode_Instruction==4'b0111)
		//begin
		//	next_state=CRC_FIFO;
		//end
		//else begin
		next_state = START;
		//end
		end
	READY4_0:		//Number 5
		begin
		load_enable = 0;
		sending=1;
		output_selection = 0;
		//if(Encode_Instruction==4'b0111)
		//begin
		//	next_state=CRC_FIFO;
		//end
		//else begin
		next_state = START_1;
		//end
		end
	READY4_1:		//Number 5
		begin
		load_enable = 0;
		sending=1;
		output_selection = 0;
		clear_crc = 0;
		if(w_enable == 1)
			next_state = START;
		else
			next_state = PRE_WRITE_DONE3;
		end
	START: 		//Number 6
		begin
		sending=1;
		load_enable = 0;
		output_selection = 0;
		enable_CRC = 1;
		if(byte_done==1 & w_enable != 0)
		begin
			next_state=SHIFT_OUT;
		end
		else if(w_enable==0 && byte_done == 1)
		begin
			next_state=PRE_WRITE_DONE;
		end
		else if(0)
		begin
			next_state=CRC_FIFO;
		end
		end
	START_1: 		//Number 6
		begin
		sending=1;
		load_enable = 0;
		output_selection = 0;
		if(byte_done==1 & w_enable != 0)
		begin
			next_state=SHIFT_OUT_1;
		end
		else if(w_enable==0 && byte_done == 1)
		begin
			next_state=PRE_WRITE_DONE;
		end
		end	
	START_0: 		//Number 6
		begin
		sending=1;
		load_enable = 0;
		output_selection = 0;
		if(byte_done==1 & w_enable != 0)
		begin
			next_state=SHIFT_OUT_0;
		end
		else if(w_enable==0 && byte_done == 1)
		begin
			next_state=PRE_WRITE_DONE;
		end
		end
	
	SHIFT_OUT_0:	//Number 7
		begin
		sending = 1;
		r_enable_e=1;
		output_selection = 0;
		if(Encode_Instruction==4'b0111)
		begin
			next_state=CRC_FIFO;
		end
		else begin
			next_state=READY3_0;
		end
			
		end
	SHIFT_OUT_1:	//Number 7
		begin
		sending = 1;
		r_enable_e=1;
		output_selection = 0;
		if(Encode_Instruction==4'b0111)
		begin
			next_state=CRC_FIFO;
		end
		else begin
			next_state=READY3_1;
		end
			
		end
	READY3_0:		//Number 4 Load 8-bit parallel data into shift register
		begin
		load_enable = 1;
		sending=1;
		r_enable_e = 0;	
		output_selection = 0;
		if(Encode_Instruction==4'b0111)
		begin
			next_state=CRC_FIFO;
		end
		else begin
		next_state = READY4_0;
		end
		end
	READY3_1:		//Number 4 Load 8-bit parallel data into shift register
		begin
		load_enable = 1;
		sending=1;
		r_enable_e = 0;	
		output_selection = 0;
		clear_crc = 1;
		if(Encode_Instruction==4'b0111)
		begin
			next_state=CRC_FIFO;
		end
		else begin
			next_state = READY4_1;
		end
		end
	SHIFT_OUT:	//Number 7
		begin
		sending = 1;
		r_enable_e=1;
		output_selection = 0;
		enable_CRC = 1;
		//if(Encode_Instruction==4'b0111)
		//begin
		//	next_state=CRC_FIFO;
		//end
		//else begin
			next_state=READY3;
		//end
			
		end
	PRE_WRITE_DONE:	//Number 10
		begin
			sending = 1;
			enable_CRC = 1;
			if (bit_ready) begin
				next_state = PRE_WRITE_DONE2;
			end
			else
				next_state = PRE_WRITE_DONE;
		end
	PRE_WRITE_DONE2:	//Number 11
		begin
			sending = 1;
			enable_CRC = 1;
			if(Encode_Instruction == 4'b0111)
				next_state = PRE_WRITE_DONE2_1;
			else if(bit_ready)
				next_state = WRITE_DONE;
			else
				next_state = PRE_WRITE_DONE2;
		end
	PRE_WRITE_DONE2_1:begin
			enable_CRC = 1;
			sending = 1;
			next_state = PRE_WRITE_DONE2_2;
		end
	PRE_WRITE_DONE2_2:begin
			enable_CRC = 1;
			sending = 1;
			next_state = PRE_WRITE_DONE2_3;
		end
	PRE_WRITE_DONE2_3: begin
			enable_CRC = 1;
			sending = 1;
			next_state = PRE_WRITE_DONE2_5;
		end
	PRE_WRITE_DONE2_4: begin
			enable_CRC = 1;
			sending = 1;
			next_state = PRE_WRITE_DONE2_5;
		end
	PRE_WRITE_DONE2_5: begin
			enable_CRC = 0;
			output_selection = 1;
			ack = CRC[15:8];
			ACK_Enable = 1;
			sending = 1;
			next_state = PRE_WRITE_DONE2_6;
		end
	PRE_WRITE_DONE2_6: begin
			enable_CRC = 0;
			output_selection = 1;
			ack = CRC[15:8];
			ACK_Enable = 1;
			sending = 1;
			next_state = PRE_WRITE_DONE2_7;
		end
	PRE_WRITE_DONE2_7: begin
			enable_CRC = 0;
			output_selection = 1;
			ACK_Enable = 0;
			ack = CRC[7:0];
			sending = 1;
			r_enable_e=1;
			
			next_state = PRE_WRITE_DONE2_8;
		end
	PRE_WRITE_DONE2_8: begin
			enable_CRC = 0;
			output_selection = 1;
			load_enable = 1;
			ACK_Enable = 1;
			ack = CRC[7:0];
			r_enable_e=0;
			sending = 1;
			next_state = PRE_WRITE_DONE2_9;
		end
	PRE_WRITE_DONE2_9: begin
			enable_CRC = 0;
			output_selection = 1;
			ACK_Enable = 1;
			ack = CRC[7:0];
			sending = 1;
			next_state = START_10;
		end
	START_10: begin
		sending=1;
		load_enable = 0;
		output_selection = 0;
		//enable_CRC = 1;
		if(byte_done==1 & w_enable != 0)
		begin
			next_state=SHIFT_OUT_10;
		end
		else if(w_enable==0 && byte_done == 1)
		begin
			next_state=PRE_WRITE_DONE3;
		end
	end
			
	SHIFT_OUT_10:	//Number 7
		begin
		sending = 1;
		r_enable_e=1;
		output_selection = 0;
		enable_CRC = 1;
		next_state=READY3_10;		
	end
	
	READY3_10:		//Number 4 Load 8-bit parallel data into shift register
		begin
		load_enable = 1;
		sending=1;
		r_enable_e = 0;	
		output_selection = 0;
		next_state = READY4_10;
		if(w_enable == 0)
			next_state = PRE_WRITE_DONE3;
	end
	
	READY4_10:		//Number 5
		begin
		load_enable = 0;
		sending=1;
		output_selection = 0;
		next_state = START_10;
	end

	PRE_WRITE_DONE3: begin
			sending = 1;
			if (bit_ready) begin
				next_state = PRE_WRITE_DONE4;
			end
			else
				next_state = PRE_WRITE_DONE3;
		end
	PRE_WRITE_DONE4: begin
			sending = 1;
			if (bit_ready) begin
				next_state = WRITE_DONE;
			end
			else
				next_state = PRE_WRITE_DONE4;
		end
	/*PAUSE_WRITE_DONE: begin
			sending = 0;			//Probably
			selection=1;
			if(eop_done==1)
			begin
				next_state=PAUSE_DONE;
			end
			else
			begin
				next_state=PAUSE_WRITE_DONE;
			end
	end*/

	WRITE_DONE:	//Number 8
		begin
			sending = 0;			//Probably
			selection=1;
			freeze = 1;
			if(eop_done==1)
			begin
				next_state=PAUSE_DONE;
			end
			else
			begin
				next_state=WRITE_DONE;
			end
		end
	PAUSE_DONE:	//Number 9
		begin
			freeze = 1;
			selection=0;
			next_Encode_Status = 3'b010;
			if(Encode_Instruction == 4'b0110)
				next_Encode_Status = 3'b010;
			next_state=PAUSE_DONE2;
		end
	PAUSE_DONE2: begin
			freeze = 1;
			selection=0;
			next_Encode_Status = 3'b010;
			if(Encode_Instruction == 4'b0110)
				next_Encode_Status = 3'b010;
			next_state=DONE;
		end
 	DONE:	//Number 9
		begin
			selection=0;
			freeze = 1;
			next_Encode_Status = 3'b010;
			if(Encode_Instruction == 4'b0110)
				next_Encode_Status = 3'b010;
			next_state=IDLE;
		end
		


	ACK1:begin //10
		ack=8'b10000000;
		output_selection=1'b1;
		ACK_Enable=1'b0;
		next_state=ACK1_1;
		end
	ACK1_1:begin //10
		ack=8'b10000000;
		output_selection=1'b1;
		ACK_Enable=1'b1;
		next_state=ACK2;
		end
	ACK2:
		begin
			ack=8'b10000000;//11
			output_selection=1;
			ACK_Enable=1'b1;
			next_state=ACK2_1;
		end
	ACK2_1:
		begin
			ack=8'b10000000;//11
			output_selection=1;
			ACK_Enable=0;
			next_state=ACK3;
		end
	ACK3:
		begin//12
			ack=8'b00101101;
			ACK_Enable=0;
			output_selection=1;
			next_state=ACK3_1;
		end
	ACK3_1:
		begin//12
			ack=8'b00101101;
			ACK_Enable=1;
			output_selection=1;
			next_state=ACK4;
		end
	ACK4://13
		begin
			ack=8'b00101101;
			ACK_Enable=1'b1;
			output_selection=1;
			next_state=ACK4_1;
		end

	ACK4_1://13
		begin
			ack=8'b00101101;
			ACK_Enable=1'b0;
			output_selection=1;
			next_state=READY0;
		end

	ACKB1:begin//14
		ack=8'b10000000;
		output_selection=1'b1;
		ACK_Enable=1'b1;
		next_state=ACKB1_1;
		end
	ACKB1_1:begin//14
		ack=8'b10000000;
		output_selection=1'b1;
		ACK_Enable=1'b1;
		next_state=ACKB2;
		end
	ACKB2://15
		begin
			ack=8'b10000000;
			output_selection=1;
			ACK_Enable=0;
			next_state=ACKB2_1;
		end
	ACKB2_1://15
		begin
			ack=8'b10000000;
			output_selection=1;
			ACK_Enable=0;
			next_state=ACKB3;
		end
	ACKB3://16
		begin
			ack=8'b00101101;
			ACK_Enable=1;
			output_selection=1;
			next_state=ACKB3_1;
		end
	ACKB3_1://16
		begin
			ack=8'b00101101;
			ACK_Enable=1;
			output_selection=1;
			next_state=ACKB4;
		end
	ACKB4://17
		begin
			ACK_Enable=1'b0;
			output_selection=1;
			next_Encode_Status=2'b01;
			next_state=ACK4_1;
		end
	ACKB4_1://17
		begin
			ACK_Enable=1'b0;
			output_selection=1;
			next_Encode_Status=2'b01;
			next_state=READY0;
		end

	SYNC1:	//18
		begin
			ack=8'b10000000;//???
			output_selection=1;
			ACK_Enable=1;
			freeze = 1;
			next_state=SYNC1_1;
		end
	SYNC1_1:	//18
		begin
			ack=8'b10000000;//???
			output_selection=1;
			ACK_Enable=1;
			next_state=SYNC2;
		end
	SYNC2: //19
		begin

			ack=8'b10000000;
			output_selection=1;
			ACK_Enable=0;
			next_state=SYNC2_1;
		end
	SYNC2_1: //19
		begin

			ack=8'b10000000;
			output_selection=1;
			ACK_Enable=0;
			next_state=DATA1_1;
		end
	DATA1_1://20
		begin
			ack=8'b10110100;
			ACK_Enable=1;
			output_selection=1;
			next_state=DATA1_1_1;
		end
	DATA1_1_1://20
		begin
			ack=8'b10110100;
			ACK_Enable=1;
			output_selection=1;
			next_state=DATA1_2;
		end
	DATA1_2://21
		begin
			ACK_Enable=1'b0;
			output_selection=1'b0;
			if(Encode_Instruction==4'b0101)
			begin
				next_state=READY0;
			end
			else
			begin	
				next_state=DATA1_2;
			end
		end
	CRC_FIFO: begin//21
		next_state=START;
		end

	endcase
end

assign clear = Clear;
endmodule
