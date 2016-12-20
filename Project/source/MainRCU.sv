// $Id: $
// File name:   MainRCU.sv
// Created:     11/28/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Main RCU, the coordinator of USB transmitter and USB receiver.
module MainRCU(
input wire clk,
input wire n_rst,
input reg [7:0] Rcv_data,
input wire R_error,
input wire [2:0] StatusIn,
input wire [3:0] Decode_Status,
input wire [2:0] Encode_Status,
input wire eop, 
output reg [7:0] Address,
output reg [3:0] Request,
//output logic Ena_Decode,
output reg [3:0] Encode_Instruction,
output reg USBOE,
output logic [2:0] Decode_Instruction,
output reg Restart
);



typedef enum logic [6:0] {IDLE, READ, WRITE, ERASE, R_WAIT, R_WAIT_2, W_WAIT, E_WAIT, MAX_PACKET, ERROR_R, ERROR_W, ADD_EQ1, DUMMY1, REVERT1, ADD_EQ2, DUMMY2, REVERT2,
ADD_EQ3, DUMMY3, REVERT3, ACK_RW, CHECK_TOKEN, READ_T, WAIT1, WAIT2, ADD_CRC, WASTE, CHK_ACK, WRITE_T, W_SUCCESS, W_FLASH, ENC_GOOD_REPEAT,
E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E12, WAIT_ERASE, ACK_GOOD, ACK_BAD, RESUME1, RESUME2, RESUME3, WAIT2_1, ATTACHSYNCDATA1, ATTACHSYNCDATA2, WAITATTACHSYNCDATA1, WASTE2, MAX_PACKET2, WASTE3, W1,W2,W3,W4,W5,W6,W7,WACK_RW,REVERT4,RESET1, ACK_RW1, PREACK_RW,ACK_RW2} state;
state current_state;
state next_state;

reg [3:0] Req_orig;
reg [3:0] next_Req_orig;
reg [7:0] next_Address;
reg Success;
reg next_Success;
reg [3:0] next_Encode_Instruction;
reg [2:0] next_Decode_Instruction;
reg next_USBOE;
reg [2:0] next_Status;
reg [2:0] Status;
//reg Store_Status;
//reg next_Store_Status;

always_ff @ (posedge clk, negedge n_rst)
begin
	if(n_rst==0)
	begin
		current_state <= IDLE;
		USBOE <= 0;
		Req_orig <= 0;
		Address <= '0;
		Success <= 0;
		Encode_Instruction <= 0;
		Decode_Instruction <= 0;
		Status <= '0;
		//Store_Status <= 0;
	end
	else
	begin
		Req_orig <= next_Req_orig;
		current_state<=next_state;
		USBOE <= next_USBOE;
		Address <= next_Address;
		Success <= next_Success;
		Encode_Instruction <= next_Encode_Instruction;
		Decode_Instruction <= next_Decode_Instruction;
		Status <= next_Status;
		//Store_Status <= next_Store_Status;
	end
end




always_comb
begin
next_USBOE = USBOE;
next_Address = Address;
Request = '0;
next_Encode_Instruction = Encode_Instruction;
next_Decode_Instruction = Decode_Instruction;
next_Success = Success;
next_state = current_state;
next_Req_orig = Req_orig;
next_Status = StatusIn;
Restart = 0;
case(current_state)
	IDLE://1
		begin
			Request = '0;
			next_Decode_Instruction = '0;
			next_Encode_Instruction = '0;
			if(Decode_Status==4'b0101)
			begin
				next_state=READ;
			end
			else if(Decode_Status==4'b0110)
			begin
				next_state=WRITE;
			end
			else if(Decode_Status==4'b0111)
			begin
				next_state=ERASE;
			end
			else
				next_state = IDLE;
			


		end
	READ://2
	begin
		Request=4'b0001;
		next_Decode_Instruction = 3'b001;
			if(Decode_Status==4'b1010) begin
				next_state=R_WAIT;
			end
			else begin
				next_state=READ;
			end			
		
	end

	R_WAIT:begin
		next_USBOE = 1;
		next_Encode_Instruction=4'b0110;
		if(Encode_Status==3'b010)
		begin
			next_state=RESUME1;
		end
		else begin
			next_state=R_WAIT;
		end	
	end
	
	RESUME1: begin
		next_USBOE = 0;
		next_Encode_Instruction = '0;
		next_Decode_Instruction = '0;
		Request = 4'b0001;
		if (Decode_Status == 4'b0011) begin
			next_state = ADD_EQ1;
			next_Address = Rcv_data;
		end
		else
			next_state = RESUME1;
		next_Req_orig = Request;
	end

	RESUME2: begin
		next_USBOE = 0;
		next_Encode_Instruction = '0;
		next_Decode_Instruction = '0;
		Request = 4'b0010;
		if (Decode_Status == 4'b0011) begin
			next_state = ADD_EQ1;
			next_Address = Rcv_data;
		end
		else
			next_state = RESUME2;
		next_Req_orig= Request;
	end

	RESUME3: begin
		next_USBOE = 0;
		next_Encode_Instruction = '0;
		next_Decode_Instruction = '0;
		Request = 4'b0011;
		if (Decode_Status == 4'b0011) begin
			next_state = ADD_EQ1;
			next_Address = Rcv_data;
		end
		else
			next_state = RESUME3;
		next_Req_orig= Request;
	end
	
	WRITE://3
	begin
		Request=4'b0010;
		if(Decode_Status==4'b1010) begin
			next_state=W_WAIT;
		end
		else begin
			next_state=WRITE;
		end			
	end

	W_WAIT:
	begin
		next_Encode_Instruction=4'b0110;
		next_USBOE = 1;
		if(Encode_Status==3'b010)
		begin
                        next_Encode_Instruction = 0;	//Added 12/13
			next_state=RESUME2;
		end
		else begin
			next_state=W_WAIT;
		end


	end

	ERASE:begin//4
		Request=4'b0011;
		if(Decode_Status==4'b1010) begin
			next_state=E_WAIT;
		end
		else begin
			next_state=ERASE;
		end			
		
		
	end
	E_WAIT:begin
		next_USBOE = 1;
		next_Encode_Instruction=4'b0110;
		if(Encode_Status==3'b010)
		begin
			next_state=RESUME3;
		end
		else begin
			next_state=E_WAIT;
		end
	end

	

	MAX_PACKET://5
		begin
			Request = '0;
			next_USBOE = 1;
			next_Encode_Instruction = 4'b0111;
			if(Encode_Status == 3'b010)
				next_state=WASTE;
			else if(Status == '1) begin		//DATA TRANSFERRED SUCCESSFULLY!!!
				next_state = MAX_PACKET2;
			end
			else
				next_state = MAX_PACKET;
		end

	MAX_PACKET2://5
		begin
			Request = '0;
			next_USBOE = 1;
			next_Encode_Instruction = 4'b0111;
			if(Encode_Status == 3'b010)
				next_state=WASTE2;
			else
				next_state = MAX_PACKET2;
		end
	ERROR_R://6
		begin
		next_state=IDLE;
		end
	ERROR_W://7
		begin
		next_state=ACK_BAD;
		end


	ADD_EQ1:begin//8
		
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=DUMMY1;
		end
	DUMMY1: begin//9
		next_state=REVERT1;
		next_Address=Rcv_data;
		Request = 4'b0111;
		end
	REVERT1:
		begin
			Request = Req_orig;
			if(Decode_Status==4'b0011)
			begin	
				next_state=ADD_EQ2;
			end
			else begin
				next_state=REVERT1;
			end

		end

	ADD_EQ2:begin//10
		//next_Req_orig=Request;
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=DUMMY2;
		end
	DUMMY2: begin//11
		next_state=REVERT2;
		next_Address=Rcv_data;
		Request = 4'b0111;
		end
	REVERT2://12
		begin
			Request = Req_orig;
			if(Decode_Status==4'b0011)
			begin	
				next_state=ADD_EQ3;
			end
			else begin
				next_state=REVERT2;
			end

		end
	ADD_EQ3:begin//13
		//next_Req_orig=Request;
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=DUMMY3;
		end
	DUMMY3: begin//14
		next_state=REVERT3;
		next_Address=Rcv_data;
		Request = 4'b0111;
		end
	REVERT3://15
		begin
			Request= Req_orig;
                        if(Decode_Status == 4'b1010 && (Request == 4'b0010 || Request == 4'b0101)) begin
                                next_state = ACK_RW1;
                                next_USBOE = 1;
                                next_Encode_Instruction = 1;
                        end
			else if (Decode_Status == 4'b1010 && Request != 4'b0011) begin
				next_state=ACK_RW;
			        next_Encode_Instruction=4'b0110;
                        end
			else if(Request == 4'b0011 && (Status == 3'b110 || Status == 3'b011)) begin
				next_state = ACK_GOOD;
                        end 
			else begin
				next_state = REVERT3;
                        end
		end
        ACK_RW1: begin //30
                        next_USBOE = 1;
                        next_Encode_Instruction= '0;
                        Request = 4'b0010;
                         if(Status == 3'b101)  begin
                            next_state = ACK_RW2;
                             next_Encode_Instruction=4'b0110;
                         end
                         else begin
                            next_state = ACK_RW1;
                         end
                      end  
	ACK_RW2: begin
                        Request = 4'b0010;
			next_USBOE = 1;
			next_Encode_Instruction=4'b0110;
			if(Status == 3'b101)
                              Request= 4'b1111;
			if ((Encode_Status == 3'b001 || Encode_Status == 3'b010) && (Request == 4'b0010 || Request == 4'b1111)) begin
                                next_state = CHECK_TOKEN;
                                next_Encode_Instruction = 4'b0000;
                        end
                        else
				next_state = ACK_RW2;
	end
        

	PREACK_RW://16
		begin
			next_USBOE = 1;
			next_Encode_Instruction=4'b0110;
			next_state = ACK_RW;
		end
	ACK_RW: begin
			next_USBOE = 1;
			next_Encode_Instruction=4'b0110;
			if(Status == 3'b101)
                              Request= 4'b1111;
			Request = Req_orig;
			if((Encode_Status == 3'b001 || Encode_Status == 3'b010) && (Request != 4'b0010))
				next_state = WAITATTACHSYNCDATA1;
			else if ((Encode_Status == 3'b001 || Encode_Status == 3'b010) && (Request == 4'b0010 || Request == 4'b1111)) begin
                                next_state = CHECK_TOKEN;
                                next_Encode_Instruction = 4'b0000;
                        end
                        else
				next_state = ACK_RW;
	end
        
        WAITATTACHSYNCDATA1:
		begin
			next_USBOE = 0;
			next_Encode_Instruction = '0;
			if(Decode_Status == 4'b1011)
				next_state = ATTACHSYNCDATA1;
			else
				next_state = WAITATTACHSYNCDATA1;
		end
	ATTACHSYNCDATA1:
		begin
			next_USBOE = 1;
			next_Encode_Instruction = 4'b0100;	//ATTACH SYNC, DATA1 IN FIFO
			if(Encode_Status == 3'b011)
				next_state = CHECK_TOKEN;
			else if (Status == 3'b001)
				next_state = CHECK_TOKEN;
			else
				next_state = ATTACHSYNCDATA1;
			
		end

	ATTACHSYNCDATA2:
		begin
			next_USBOE = 0;
			next_Encode_Instruction = 4'b0100;	//ATTACH SYNC, DATA1 IN FIFO
			next_state = CHECK_TOKEN;
			
		end
	CHECK_TOKEN://17
		begin
			next_USBOE = 0;
			next_Decode_Instruction = '0;
			next_Encode_Instruction = '0;
			if(Decode_Status == 4'b1011 && Req_orig==4'b0001) begin
				next_state=READ_T;
			end
			else if(Req_orig==4'b0010) begin
				next_state=WRITE_T;
                                next_USBOE = 0;
			end
		end


	READ_T:begin//18
		next_USBOE = 0;
		next_Encode_Instruction=4'b0101;
		//next_Encode_Instruction = 4'b0100;
		Request=4'b1000;
		next_state=WAIT1;
		end
	WAIT1:begin//19
		next_USBOE = 0;
		Request=4'b1000;
		next_state=WAIT2;
		end
	WAIT2:begin//20
		next_USBOE = 1;
		Request = Req_orig;
		if(Status==3'b111) begin
			next_state=ADD_CRC;
		end
		else if(Status==3'b100)
		begin
			next_state=MAX_PACKET;
		end
		//else if(Status == 3'b001) begin
		//	next_state = WAIT2_1;
		//end
		else begin
			next_state=WAIT2;
		end
	end
	
	WAIT2_1: begin
		next_Encode_Instruction = 4'b0001;
		next_state = WAIT2_1;
	end	

	/*ADD_CRC:begin//21
		Request = '0;
		next_Encode_Instruction=3'b111;
		//next_Store_Status=Status;
		next_state=WASTE;
	end*/
	WASTE:begin//22
		next_USBOE = 0;
		next_Encode_Instruction=4'b0000;
		if(Decode_Status==4'b1000) begin
			next_state=CHK_ACK;
		end
		else if(Decode_Status == 4'b1001)
		begin
			next_state=ERROR_R;//bad
		end
	end

	WASTE2:begin//22
		next_Encode_Instruction=4'b0000;
		next_USBOE = 0;
		if(Decode_Status==4'b1000) begin
			next_state=WASTE3;
		end
		else if(Decode_Status == 4'b1001)
		begin
			next_state=ERROR_R;//bad
		end
	end	

	WASTE3:begin//22
		next_Encode_Instruction=4'b0000;
		next_Decode_Instruction = '1;
		next_state=IDLE;
	end	

	CHK_ACK://23
		begin
		//Ena_Decode=1'b1;
		//if(Store_Status==4'b0111) begin
		//	next_state=IDLE;
		//end
		next_Encode_Instruction = 4'b0100;
		if(Decode_Status == 4'b1011) begin
			next_state=ATTACHSYNCDATA2;
		end
		else begin
			next_state=CHECK_TOKEN;
		end
		end
	WRITE_T://24
	begin
                next_USBOE = 0;
		//Ena_Decode=1'b1;
                next_Encode_Instruction = 3'b000;
                next_Decode_Instruction = 3'b110;
                Request = 4'b0010;
                if(Status == 3'b100) begin
                        next_state = WRITE_T;
                        next_Decode_Instruction = 3'b011;
                         if(Decode_Status == 4'b1111) begin
                            next_state = REVERT4;
                         end
                end 
		else if(Decode_Status ==4'b0010)
		begin
			next_state =W1;
		end
		else if (Status==3'b011) begin
			next_state=ERROR_W;
		end
                else if (Status==3'b010)begin
                        next_state = W_FLASH;
                end
                else begin
                        next_state = WRITE_T;
                end
	end
		
        W1: begin 
             Request = 4'b0010;
             next_state = W2;
        end
        W2:begin
             Request = 4'b0010;
             next_state = W3;
        end
        W3:begin
             Request = 4'b0010;
             next_state = W4;
        end
        W4:begin
             Request = 4'b0101;
             next_state = W5;
        end
        W5:begin 
             Request = 4'b0101;
             next_state = W6;
        end
        W6:begin
             Request = 4'b0101;
             next_state = W7;
        end
        W7:begin
              Request = 4'b0101;
              next_state = WRITE_T;
              next_USBOE = 0;
        end
	
	


	W_FLASH://26
	begin
		next_Encode_Instruction=4'b0010;
                next_Decode_Instruction = 3'b101;
		Restart = 1;
		next_state = IDLE;
	end

        REVERT4: begin
			if (Decode_Status == 4'b1010)
				next_state=WACK_RW;
			else
				next_state = REVERT4;
		end

        WACK_RW://16
	begin
	next_USBOE = 1;
	next_Encode_Instruction=4'b0110;
	if((Encode_Status == 3'b001 || Encode_Status == 3'b010) && (Status != 3'b010)) begin
		next_state = RESET1;
                next_Decode_Instruction = 4'b0000;
                next_Encode_Instruction = 4'b0000;
         end
	else if ((Encode_Status == 3'b001 || Encode_Status == 3'b010) && (Status == 3'b010)) begin
                next_state = IDLE;
          end
         else begin
	        next_state = WACK_RW;
          end
	end
	RESET1: begin
        next_Decode_Instruction = 4'b0000;
        next_Encode_Instruction = 4'b0000;
             if(Decode_Status ==4'b1010)  begin
                          next_state = WRITE_T;
                          next_USBOE = 1;
                next_Encode_Instruction = 3'b000;
                next_Decode_Instruction = 3'b110;
             end
             else  begin 
                     next_state = RESET1;
                     next_Decode_Instruction = 4'b0000;
                     next_Encode_Instruction = 4'b0000; 
            end
      end
              
      ENC_GOOD_REPEAT: begin//27
		if(Encode_Status==3'b001) begin
			next_state=IDLE;
		end
		else begin
			next_state=ENC_GOOD_REPEAT;
		end
	end
	

	E1:begin//28
		next_Req_orig = Request;
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=E2;
		end
	E2: begin//29
		next_state=E3;
	end
	E3://30
		begin
			Request = Req_orig;
			if(Decode_Status==4'b0011)
			begin	
				next_state=E4;
			end
			else begin
				next_state=E3;
			end

		end

	E4:begin//31
		next_Req_orig = Request;
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=E5;
		end
	E5: begin//32
		next_state=E6;
		end
	E6://33
		begin
			Request = Req_orig;
			if(Decode_Status==4'b0011)
			begin	
				next_state=E7;
			end
			else begin
				next_state=E6;
			end

		end

	E7:begin//34
		next_Req_orig = Request;
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=E8;
		end
	E8: begin//35
		next_state=E9;
		end
	E9://36
		begin
			Request = Req_orig;
			if(Decode_Status==4'b0011)
			begin	
				next_state=E10;
			end
			else begin
				next_state=E9;
			end

		end

	E10:begin//37
		next_Req_orig = Request;
		Request=4'b0111;
		next_Address=Rcv_data;
		next_state=E11;
		end
	E11: begin//38
		next_state=E12;
		end
	E12://39
		begin
			Request = Req_orig;
			
				next_state=WAIT_ERASE;
			

		end
		

	WAIT_ERASE:begin//40
		if(Status==3'b110)begin
			next_state=ACK_GOOD;
		end
		else if(Status==3'b011) begin
			next_state=ACK_BAD;
		end
		


		else begin
			next_state=WAIT_ERASE;
		end
	end
	ACK_GOOD:begin//41
		next_Encode_Instruction=4'b0110;
		Request = '0;
		next_USBOE = 1;
		if(Encode_Status == 3'b001 || Encode_Status == 3'b010) begin
			next_state=IDLE;
			Restart = 1;
			next_USBOE = 0;
		end
		else
			next_state = ACK_GOOD;
		end
	ACK_BAD: begin//42
		next_Encode_Instruction=4'b0011;
		Request = '0;
		next_USBOE = 1;
		if(Encode_Status == 3'b001 || Encode_Status == 3'b010)
			next_state=IDLE;
		else
			next_state = ACK_BAD;
		end
	endcase
end
endmodule

