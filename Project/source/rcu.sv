// $Id: $
// File name:   rcu.sv
// Created:     10/21/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: RCU Block, the state machine that handles receiving USB data packets.
//
//

module rcu(
	input wire clk,
	input wire n_rst,
	input wire d_edge,
	input wire eop,
	input wire shift_enable,
	input wire [7:0] rcv_data,
	input wire byte_received,
	input wire [15:0] CRC16,
	input wire [4:0] CRC5,
	input wire [2:0] Decode_Instruction,
	input wire Restart,
	output reg rcving,
	output reg w_enable,
	output reg r_error,
	output reg [3:0] d_status,
	output reg enable_CRC5,
	output reg enable_CRC16,
	output reg ClearCRC
);

	localparam SYNC_BYTE = 8'b10000000;
	localparam SETUP_ID = 8'b11010010;
	localparam DATA0 = 8'b00111100;
	localparam OUT_ID = 8'b00011110;
	localparam DATA1 = 8'b10110100;
	localparam IN_ID = 8'b10010110;
	localparam ACK_PASS = 8'b00101101;
	localparam ACK_FAIL = 8'b10100101;
	localparam READ = 8'b00000001;
	localparam WRITE = 8'b00000010;
	localparam ERASE = 8'b00000011;
	reg [3:0] next_d_status;
	reg next_Success;
	reg Success;
	//localparam SYNC_BYTE = 8'b01010100;

	typedef enum logic[8:0] {WAIT,WAIT1,WAIT2, WAIT21, WAIT22, WAIT23, WAIT24, WAIT3,WAIT4,WAIT5,IDLE,IDLE1,IDLE2,IDLE3,IDLE4,IDLE5, RECEIVING, RECEIVING1, RECEIVING2, RECEIVING3, RECEIVING4, RECEIVING5, CHECK_SYNC, CHECK_SYNC1, CHECK_SYNC2, CHECK_SYNC3, CHECK_SYNC4,CHECK_SYNC5, MATCH_WAIT, MATCH_WAIT1, MATCH_WAIT2, MATCH_WAIT3, MATCH_WAIT4, MATCH_WAIT5, NO_MATCH, NO_MATCH1, NO_MATCH2, NO_MATCH3, NO_MATCH4, NO_MATCH5, NO_MATCH_ERROR, NO_MATCH_ERROR1, NO_MATCH_ERROR2, NO_MATCH_ERROR3, NO_MATCH_ERROR4, NO_MATCH_ERROR5, BIT_RECEIVED, DATA_WRITE, DATA_WAIT_NEXT, EOP_ERR, EOP_ERR1, EOP_ERR2, EOP_ERR3, EOP_ERR4, EOP_ERR5, EOP_WAIT, EOP_WAIT1, EOP_WAIT2, EOP_WAIT3, EOP_WAIT4, EOP_WAIT5, ERR, ERR1,ERR2, ERR3,ERR4, ERR5, CHECK_DATA, CHECK_DATA1, CHECK_DATA2, CHECK_DATA3, CHECK_DATA4, CHECK_DATA5, CHECK_DATA6, CHECK_DATA7, CHECK_DATA8, CHECK_DATA9, CHECK_DATA10, CHECK_DATA11, CHECK_DATA12, CHECK_DATA13, CRC_CHECK, CRC_CHECK2, CRC_CHECK3, CRC_CHECK4, BIT_RECEIVED1, BIT_RECEIVED2, DATA_WRITE1, DATA_WAIT_NEXT1, DATA_WRITE2, DATA_WAIT_NEXT2, BIT_RECEIVED3, BIT_RECEIVED4, BIT_RECEIVED5, BIT_RECEIVED6, BIT_RECEIVED7, BIT_RECEIVED8, BIT_RECEIVED9, BIT_RECEIVED10, BIT_RECEIVED11, BIT_RECEIVED12, BIT_RECEIVED13, BIT_RECEIVED14, BIT_RECEIVED15, BIT_RECEIVED16, BIT_RECEIVED17, BIT_RECEIVED18, BIT_RECEIVED19, BIT_RECEIVED20, BIT_RECEIVED21, BIT_RECEIVED22, BIT_RECEIVED23, BIT_RECEIVED24, BIT_RECEIVED25, BIT_RECEIVED26, BIT_RECEIVED27, BIT_RECEIVED28, BIT_RECEIVED29, BIT_RECEIVED30, BIT_RECEIVED31, BIT_RECEIVED33, BIT_RECEIVED34, DATA_WRITE3, DATA_WRITE4, DATA_WRITE5, DATA_WRITE6, DATA_WRITE7, DATA_WRITE8, DATA_WRITE9, DATA_WRITE10, DATA_WRITE11, DATA_WRITE12, DATA_WRITE13, DATA_WRITE14, DATA_WRITE15, DATA_WRITE16, DATA_WRITE17, DATA_WRITE18, DATA_WRITE19, DATA_WRITE20, DATA_WRITE21, DATA_WRITE22, DATA_WRITE23, DATA_WRITE24, DATA_WRITE25, DATA_WRITE26, DATA_WRITE27, DATA_WRITE28, DATA_WRITE29, DATA_WRITE30, DATA_WRITE31, DATA_WRITE33, DATA_WRITE34, DATA_WAIT_NEXT3, DATA_WAIT_NEXT4, DATA_WAIT_NEXT5, DATA_WAIT_NEXT6, DATA_WAIT_NEXT7, DATA_WAIT_NEXT8, DATA_WAIT_NEXT9, DATA_WAIT_NEXT10, DATA_WAIT_NEXT11, DATA_WAIT_NEXT12, DATA_WAIT_NEXT13, DATA_WAIT_NEXT14, DATA_WAIT_NEXT15, DATA_WAIT_NEXT16, DATA_WAIT_NEXT17, DATA_WAIT_NEXT18, DATA_WAIT_NEXT19, DATA_WAIT_NEXT20, DATA_WAIT_NEXT21, DATA_WAIT_NEXT22, DATA_WAIT_NEXT23, DATA_WAIT_NEXT24, DATA_WAIT_NEXT25, DATA_WAIT_NEXT26, DATA_WAIT_NEXT27, DATA_WAIT_NEXT28, DATA_WAIT_NEXT29, DATA_WAIT_NEXT30, DATA_WAIT_NEXT31, DATA_WAIT_NEXT33, DATA_WAIT_NEXT34, IDLE_0, RECEIVING_0, CHECK_SYNC_0, NO_MATCH_0, NO_MATCH_ERROR_0, MATCH_WAIT_0, BIT_RECEIVED_0, CHECK_DATA_0, DATA_WRITE_0, DATA_WAIT_NEXT_0, BIT_RECEIVED1_0, CHECK_DATA1_0, DATA_WRITE1_0, DATA_WAIT_NEXT1_0, BIT_RECEIVED2_0, CHECK_DATA2_0, DATA_WRITE2_0, DATA_WAIT_NEXT2_0, WAIT1_0, EOP_WAIT_0, DATA_WAIT_NEXT27_2, DATA_WAIT_NEXT27_1, DATA_WAIT_NEXT27_0, DATA_WRITE27_0, DATA_WRITE27_1, DATA_WRITE27_2, BIT_RECEIVED27_0, BIT_RECEIVED27_1, BIT_RECEIVED27_2, BIT_RECEIVED27_3, DATA_WRITE27_3, WAIT4_0, WAIT4_1, WAIT4_2, WAIT4_3, WAIT4_4, WAIT4_5, WAIT4_6, BIT_RECEIVED23_0, BIT_RECEIVED23_1, BIT_RECEIVED23_2, DATA_WRITE23_0, DATA_WRITE23_1, DATA_WRITE23_2, DATA_WAIT_NEXT23_0, DATA_WAIT_NEXT23_1, DATA_WAIT_NEXT23_2, DATA_WAIT_NEXT23_3, DATA_WRITE23_3, BIT_RECEIVED23_3, DATA_WAIT_NEXT21_0, DATA_WAIT_NEXT21_1, DATA_WAIT_NEXT21_2, DATA_WRITE21_0, DATA_WRITE21_1, DATA_WRITE21_2, BIT_RECEIVED21_0, BIT_RECEIVED21_1, BIT_RECEIVED21_2, PRE_IDLE4_3, PRE_IDLE4_2, PRE_IDLE4_1, PRE_IDLE4_0, CHECK_DATA60, WRITE_BIT_RECEIVE1,WRITE_BIT_RECEIVE2,WRITE_BIT_CHECK1, WRITE_BIT_CHECK2,WRITE_BIT_WAIT1,WRITE_BIT_WAIT2,WRITE_BIT_WAIT3,GOBACK,WRITEWAIT1,WRITEWAIT2,WRITEWAIT3,WRITEWAIT4,WRITEWAIT5,WRITEWAIT6, CRC_CHECK4_nxt, WAIT0, EOPDUMMY} state_type;
	state_type curr_state, next_state;

	always_ff @ (posedge clk, negedge n_rst)
	begin
		if( !n_rst )
		begin
				curr_state <= WAIT;
				Success <= 0;
				d_status <= 0;
		end
		else if(Restart) begin
			curr_state <= WAIT;
				Success <= 0;
				d_status <= 0;
		end
		else
		begin
			curr_state <= next_state;
			Success <= next_Success;
			d_status <= next_d_status;
		end
	end

	always_comb
	begin
		next_state = curr_state;
		rcving = 1'b0;
		w_enable = 1'b0;
		r_error = 1'b0;
                next_d_status = d_status;
		enable_CRC5 = '0;
		enable_CRC16 = '0;
		ClearCRC = 0;
		next_Success = Success;		

		case(curr_state)

			WAIT: //1
			begin
				next_d_status = 4'b0000;
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_state = IDLE;
			end

			IDLE: //2
			begin
				next_d_status = 4'b0000;
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 )
					next_state = RECEIVING;
				else
					next_state = IDLE;
			end
 
			RECEIVING: //3
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC;
				else
					next_state = RECEIVING;
			end

			CHECK_SYNC: //4 
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR;


			end

			NO_MATCH: //5
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR;
				else
				  next_state = NO_MATCH;
			   
			end

			NO_MATCH_ERROR: //6
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR;
				else
					next_state = NO_MATCH_ERROR;
			end

			MATCH_WAIT: //7
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;	
				enable_CRC5 = 1;
				if(shift_enable == 1)
					next_state = BIT_RECEIVED;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;
			end

			BIT_RECEIVED: //8
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;
				if(byte_received == 1'b1)
					next_state = CHECK_DATA;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED;
			end
			
			CHECK_DATA: //14
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				if(rcv_data == SETUP_ID)
					next_state = DATA_WRITE;
				else
					next_state = ERR;
					
			end
			DATA_WRITE: //9
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				ClearCRC = 1;
				next_state = DATA_WAIT_NEXT;
			end

			DATA_WAIT_NEXT: //10
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//Enable CRC Generator
				
				enable_CRC5 = 1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED1;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT;
			end
			
			BIT_RECEIVED1: //15
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//Enable CRC Generator
				enable_CRC5 = 1;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA1;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED1;
			end
			
			CHECK_DATA1: //16
			begin
				//Enable CRC Generator
				enable_CRC5 = 1;

				rcving = 1'b1;
				if(rcv_data[0] != 0)
					next_state = ERR;
				else
					next_state = DATA_WRITE1;
			end

			DATA_WRITE1: //17
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//Enable CRC Generator
				enable_CRC5 = 1;

				next_state = DATA_WAIT_NEXT1;
			end

			DATA_WAIT_NEXT1: //18
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//Enable CRC Generator
				enable_CRC5 = 1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED2;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT1;
			end

			BIT_RECEIVED2: //19
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//Enable CRC Generator
				enable_CRC5 = 1;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA2;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED2;
			end
			
			CHECK_DATA2: //20
			begin
				rcving = 1'b1;
				enable_CRC5 = 1;
				//CHECK CRC 5
				if (CRC5[4:0] == '0)
					next_state = DATA_WRITE2;
				else
					next_state = ERR;
			end

			DATA_WRITE2: //21
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT2;
			end

			DATA_WAIT_NEXT2: //21
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//if(shift_enable == 1'b1 && eop == 1'b0)
				//	next_state = BIT_RECEIVED2;
				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT2;
			end
			

			EOP_WAIT: //11
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(eop == 1'b0)
					next_state = WAIT1;
				else
					next_state = EOP_WAIT;
			end

			EOP_ERR: //12
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR;
				else
					next_state = EOP_ERR;
			end

			ERR: //13
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(eop == 1'b1)
					next_state = WAIT0;
			end
			
			WAIT0: begin
				if(eop == 1'b0)
					next_state = WAIT;
				else
					next_state = WAIT0;
			end
//DATA PACKET


			WAIT1: //22
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = IDLE1;
			end

			IDLE1: //23
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 )
					next_state = RECEIVING1;
				else
					next_state = IDLE1;
			end
 
			RECEIVING1: //24
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC1;
				else
					next_state = RECEIVING1;
			end

			CHECK_SYNC1: //25 
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH1;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT1;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR1;


			end

			NO_MATCH1: //26
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR1;
				else
				  next_state = NO_MATCH1;
			   
			end

			NO_MATCH_ERROR1: //27
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR1;
				else
					next_state = NO_MATCH_ERROR1;
			end

			MATCH_WAIT1: //28
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;		
				if(shift_enable == 1)
					next_state = BIT_RECEIVED3;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;
			end

			BIT_RECEIVED3: //29			
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA3;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED3;
			end
			
			CHECK_DATA3: //30
			begin
				rcving = 1'b1;
				if(rcv_data == DATA0)
					next_state = DATA_WRITE3;
				else
					next_state = ERR;
					
			end
			DATA_WRITE3: //31
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				ClearCRC = 1;
				next_state = DATA_WAIT_NEXT3;
			end

			DATA_WAIT_NEXT3: //32
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				ClearCRC = 0;
				enable_CRC16 = 1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED4;
				//else if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT3;
			end
			
			BIT_RECEIVED4: //33
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = DATA_WRITE4;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED4;
			end
			

			DATA_WRITE4: //34
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT4;
			end

			DATA_WAIT_NEXT4: //35
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED5;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOPDUMMY;
				else
					next_state = DATA_WAIT_NEXT4;
			end

			BIT_RECEIVED5: //36
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = CHECK_DATA4;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED5;
			end
			
			CHECK_DATA4: //37
			begin
				rcving = 1'b1;
				enable_CRC16 = 1;
				if(rcv_data == READ)
					next_d_status = 4'b0101;
				else if(rcv_data == WRITE)
					next_d_status = 4'b0110;
				else if(rcv_data == ERASE)
					next_d_status = 4'b0111;

				next_state = DATA_WRITE5;
			
			end

			DATA_WRITE5: //21
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT5;
			end

			DATA_WAIT_NEXT5: //39
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED6;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOPDUMMY;
				else
					next_state = DATA_WAIT_NEXT5;
			end
			
			BIT_RECEIVED6: //40
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE6;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED6;
			end
			
			DATA_WRITE6: //41
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT6;
			end

			DATA_WAIT_NEXT6: //42
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED7;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR1;
				else
					next_state = DATA_WAIT_NEXT6;
			end	
			
			BIT_RECEIVED7: //43
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE7;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED7;
			end
			
			DATA_WRITE7: //44
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT7;
			end

			DATA_WAIT_NEXT7: //45
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED8;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOPDUMMY;
				else
					next_state = DATA_WAIT_NEXT7;
			end			
					
			BIT_RECEIVED8: //46
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE8;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED8;
			end
			
			DATA_WRITE8: //47
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT8;
			end

			DATA_WAIT_NEXT8: //48
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;	
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED9;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOPDUMMY;
				else
					next_state = DATA_WAIT_NEXT8;
			end	
		
			BIT_RECEIVED9: //49
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE9;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED9;
			end
			
			DATA_WRITE9: //50
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT9;
			end

			DATA_WAIT_NEXT9: //51
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED10;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOPDUMMY;
				else
					next_state = DATA_WAIT_NEXT9;
			end			
			BIT_RECEIVED10: //52
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE10;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED10;
			end
			
			DATA_WRITE10: //53
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT10;
			end

			DATA_WAIT_NEXT10: //54
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED11;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR1;
				else
					next_state = DATA_WAIT_NEXT10;
			end			
			BIT_RECEIVED11: //55
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE11;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED11;
			end
			
			DATA_WRITE11: //56
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT11;
			end

			DATA_WAIT_NEXT11: //57
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED33;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR1;
				else
					next_state = DATA_WAIT_NEXT11;
			end

			BIT_RECEIVED33: //55
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE33;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED33;
			end
			
			DATA_WRITE33: //56
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT33;
			end

			DATA_WAIT_NEXT33: //57
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED34;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOPDUMMY;
				else
					next_state = DATA_WAIT_NEXT33;
			end

			BIT_RECEIVED34: //55
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE34;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR1;

				else
					next_state = BIT_RECEIVED34;
			end
			
			DATA_WRITE34: //56
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = CRC_CHECK;
			end

			
			CRC_CHECK: //58
			begin
				if (CRC16 == '0)
					next_state = EOPDUMMY;	
				else
					next_state = ERR;			
			end
			
			/*CRC_CHECK2: //59
			begin
				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT1;
			end*/
                        EOPDUMMY: begin
                                rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_state = EOP_WAIT1;
			end
			EOP_WAIT1: //60
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				
				if(eop == 1'b0)
					next_state = WAIT21;
				else
					next_state = EOP_WAIT1;
			end

			WAIT21:
			begin
				next_state = WAIT22;
			end
			WAIT22:
			begin
				next_state = WAIT23;
			end
			WAIT23:
			begin
				next_state = WAIT24;
			end
			WAIT24:
			begin
				next_state = WAIT2;
			end

			EOP_ERR1: //61
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR1;
				else
					next_state = EOP_ERR1;
			end

			ERR1: //62
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(d_edge == 1'b1)
					next_state = RECEIVING1;
			end

//SETUP RECEIVE1

			WAIT2: //63
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b1010;
				if (Decode_Instruction == 3'b000)
					next_state = IDLE2;
				else
					next_state = WAIT2;
			end

			
			
			
			
			/*IDLE_0: //2
			begin
				next_d_status = 4'b0000;
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 )
					next_state = RECEIVING_0;
				else
					next_state = IDLE_0;
			end
 
			RECEIVING_0: //3
			begin
				rcving = 1'b1; 
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC_0;
				else
					next_state = RECEIVING_0;
			end

			CHECK_SYNC_0: //4 
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH_0;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT_0;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR;


			end

			NO_MATCH_0: //5
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR_0;
				else
				  next_state = NO_MATCH_0;
			   
			end

			NO_MATCH_ERROR_0: //6
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR;
				else
					next_state = NO_MATCH_ERROR_0;
			end

			MATCH_WAIT_0: //7
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;		
				if(shift_enable == 1)
					next_state = BIT_RECEIVED_0;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;
			end

			BIT_RECEIVED_0: //8
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA_0;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED_0;
			end
			
			CHECK_DATA_0: //14
			begin
				rcving = 1'b1;
				if(rcv_data == OUT_ID)
					next_state = DATA_WRITE_0;
				else
					next_state = ERR;
					
			end
			DATA_WRITE_0: //9
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				ClearCRC = 1;
				next_state = DATA_WAIT_NEXT_0;
			end

			DATA_WAIT_NEXT_0: //10
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//Enable CRC Generator
				
				enable_CRC5 = 1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED1_0;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT_0;
			end
			
			BIT_RECEIVED1_0: //15
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//Enable CRC Generator
				enable_CRC5 = 1;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA1_0;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED1_0;
			end
			
			CHECK_DATA1_0: //16
			begin
				//Enable CRC Generator
				enable_CRC5 = 1;

				rcving = 1'b1;
				if(rcv_data[0] != 0)
					next_state = ERR;
				else
					next_state = DATA_WRITE1_0;
			end

			DATA_WRITE1_0: //17
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//Enable CRC Generator
				enable_CRC5 = 1;
				next_state = DATA_WAIT_NEXT1_0;
			end

			DATA_WAIT_NEXT1_0: //18
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//Enable CRC Generator
				enable_CRC5 = 1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED2_0;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT1_0;
			end

			BIT_RECEIVED2_0: //19
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//Enable CRC Generator
				enable_CRC5 = 1;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA2_0;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;
				else
					next_state = BIT_RECEIVED2_0;
			end
			
			CHECK_DATA2_0: //20
			begin
				rcving = 1'b1;
				enable_CRC5 = 1;
				//CHECK CRC 5
				if (CRC5[4:0] == '0)
					next_state = DATA_WRITE2_0;
				else
					next_state = ERR;
			end

			DATA_WRITE2_0: //21
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT2_0;
			end

			DATA_WAIT_NEXT2_0: //21
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT_0;
				else
					next_state = DATA_WAIT_NEXT2_0;
			end
			
			EOP_WAIT_0: //11
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(eop == 1'b0)
					next_state = WAIT1_0;
				else
					next_state = EOP_WAIT_0;
			end

//address PACKET


			WAIT1_0: //22
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = IDLE2;
			end
			
			
			
			
			*/
			
			
			IDLE2: //64
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 )
					next_state = RECEIVING2;
				else
					next_state = IDLE2;
			end
 
			RECEIVING2: //65
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0001;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC2;
				else
					next_state = RECEIVING2;
			end

			CHECK_SYNC2: //66
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH2;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT2;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR2;


			end

			NO_MATCH2: //67
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR2;
				else
				  next_state = NO_MATCH2;
			   
			end

			NO_MATCH_ERROR2: //68
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR2;
				else
					next_state = NO_MATCH_ERROR2;
			end

			MATCH_WAIT2: //69
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;		
				if(shift_enable == 1)
					next_state = BIT_RECEIVED12;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR2;
			end

			BIT_RECEIVED12: //70
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA5;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR2;

				else
					next_state = BIT_RECEIVED12;
			end
			
			CHECK_DATA5: //71
			begin
				rcving = 1'b1;
				if(rcv_data == OUT_ID)
					next_state = DATA_WRITE12;
				else
					next_state = ERR2;
					
			end
			DATA_WRITE12: //72
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT12;
			end

			DATA_WAIT_NEXT12: //73
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED13;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT2;
				else
					next_state = DATA_WAIT_NEXT12;
			end
			
			BIT_RECEIVED13: //74
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA6;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED13;
			end
			
			CHECK_DATA6: //75
			begin
				rcving = 1'b1;
				enable_CRC5 = 1;
				if(rcv_data[0] != 0)
					next_state = ERR2;
				else
					next_state = DATA_WRITE13;
			end
	
			DATA_WRITE13: //76
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;
				next_state = DATA_WAIT_NEXT13;
			end

			DATA_WAIT_NEXT13: //77
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED14;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT2;
				else
					next_state = DATA_WAIT_NEXT13;
			end

			BIT_RECEIVED14: //78

			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;
				if(byte_received == 1'b1)
					next_state = CHECK_DATA7;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR2;

				else
					next_state = BIT_RECEIVED14;
			end
			
			CHECK_DATA7: //79
			begin
				rcving = 1'b1;
				//CRC CODE COMES HERE 
				enable_CRC5 = 1;
				if (CRC5[4:0] == '0)
					next_state = DATA_WRITE14;
				else
					next_state = ERR2;
			end
	

			DATA_WRITE14: //80
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT14;
			end

			DATA_WAIT_NEXT14: //81
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//if(shift_enable == 1'b1 && eop == 1'b0)
				//	next_state = BIT_RECEIVED2;
				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT2;
				else
					next_state = DATA_WAIT_NEXT14;
			end
			

			EOP_WAIT2: //82
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(eop == 1'b0)
					//next_d_status = 4'b1010;
			        //else if(Decode_Instruction == 3'b001)
				        next_state = WAIT3;
				else
					next_state = EOP_WAIT2;
			end

			EOP_ERR2: //83
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR2;
				else
					next_state = EOP_ERR2;
			end

			ERR2: //84
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(d_edge == 1'b1)
					next_state = RECEIVING2;
			end

//DATA PACKET 1

			WAIT3: //85
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = IDLE3;
			end

			IDLE3: //86
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 )
					next_state = RECEIVING3;
				else
					next_state = IDLE3;
			end
 
			RECEIVING3: //87
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC3;
				else
					next_state = RECEIVING3;
			end

			CHECK_SYNC3: //88 
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH3;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT3;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR3;


			end

			NO_MATCH3: //89
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR3;
				else
				  next_state = NO_MATCH3;
			   
			end

			NO_MATCH_ERROR3: //90
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR3;
				else
					next_state = NO_MATCH_ERROR3;
			end

			MATCH_WAIT3: //91
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;		
				if(shift_enable == 1)
					next_state = BIT_RECEIVED15;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;
			end

			BIT_RECEIVED15: //92
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA8;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED15;
			end
			
			CHECK_DATA8: //93
			begin
				rcving = 1'b1;
				enable_CRC16 = 1;
				if(rcv_data == DATA1)
					next_state = DATA_WRITE15;
				else if(rcv_data == DATA0)
					next_state = BIT_RECEIVED17;
				else
					next_state = ERR3;
					
			end
			DATA_WRITE15: //94
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT15;
			end

			DATA_WAIT_NEXT15: //95
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED16;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT15;
			end
			
			BIT_RECEIVED16: //96
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE16;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED16;
			end
			
			DATA_WRITE16: //97
			begin
				rcving = 1'b1;
				w_enable = 1'b1;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT16;
			end

			DATA_WAIT_NEXT16: //98
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED16;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT16;
			end

			BIT_RECEIVED17: //99
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = CHECK_DATA9;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED17;
			end
			
			CHECK_DATA9: //100
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				if (rcv_data == ERASE)
					next_state = DATA_WRITE17;
				else if (rcv_data == WRITE)
					next_state = DATA_WRITE22;
				else if (rcv_data == READ)
					next_state = DATA_WRITE25;
				else 
					next_state = ERR3;
			end

			DATA_WRITE17: //101
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT17;
			end

			DATA_WAIT_NEXT17: //102
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED18;
				else
					next_state = DATA_WAIT_NEXT17;
			end
			
			BIT_RECEIVED18: //103
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE18;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED18;
			
			end
			DATA_WRITE18: //104
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				next_state = DATA_WAIT_NEXT18;
			end

			DATA_WAIT_NEXT18: //105
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED19;
				else
					next_state = DATA_WAIT_NEXT18;
			end
			BIT_RECEIVED19: //106
			begin
				enable_CRC16 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE19;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED19;
			
			end
			DATA_WRITE19: //107
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				next_d_status = 4'b0011;
				next_state = DATA_WAIT_NEXT19;
			end

			DATA_WAIT_NEXT19: //108
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED20;
				else
					next_state = DATA_WAIT_NEXT19;
			end
			BIT_RECEIVED20: //109
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE20;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED20;
			
			end
			DATA_WRITE20: //110
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				next_state = DATA_WAIT_NEXT20;
				enable_CRC16 = 1;
			end

			DATA_WAIT_NEXT20: //111
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED21;
				else
					next_state = DATA_WAIT_NEXT20;
			end
			BIT_RECEIVED21: //112
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE21;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED21;
			
			end
			DATA_WRITE21: //113
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT21;
			end

			DATA_WAIT_NEXT21: //114
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED21_0;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT21;
			end


			BIT_RECEIVED21_0: //112
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE21_0;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED21_0;
			
			end
			DATA_WRITE21_0: //113
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 0;
				next_state = CRC_CHECK3;;
			end

			DATA_WAIT_NEXT21_0: //114
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = CRC_CHECK3;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT21_0;
			end


			BIT_RECEIVED21_1: //112
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE21_1;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED21_1;
			
			end
			DATA_WRITE21_1: //113
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT21_1;
			end

			DATA_WAIT_NEXT21_1: //114
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = CRC_CHECK3;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT21_1;
			end

			BIT_RECEIVED21_2: //112
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE21_2;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED21_2;
			
			end
			DATA_WRITE21_2: //113
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT21_2;
			end

			DATA_WAIT_NEXT21_2: //114
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = CRC_CHECK3;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT21_2;
			end
			
			BIT_RECEIVED22: //115
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE22;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED22;
			
			end
			DATA_WRITE22: //116
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT22;
			end

			DATA_WAIT_NEXT22: //117
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0110;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED23_0;
				else
					next_state = DATA_WAIT_NEXT22;
			end
			BIT_RECEIVED23_0: //118
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE23_0;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED23_0;
			
			end
			DATA_WRITE23_0: //119
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT23_0;
			end

			DATA_WAIT_NEXT23_0: //120
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0110;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED23_1;
				else
					next_state = DATA_WAIT_NEXT23_0;
			end

			BIT_RECEIVED23_1: //118
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE23_1;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED23_1;
			
			end
			DATA_WRITE23_1: //119
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT23_1;
			end

			DATA_WAIT_NEXT23_1: //120
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0110;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED23_2;
				else
					next_state = DATA_WAIT_NEXT23_1;
			end

			BIT_RECEIVED23_2: //118
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE23_2;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED23_2;
			
			end
			DATA_WRITE23_2: //119
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT23_2;
			end

			DATA_WAIT_NEXT23_2: //120
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0110;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED23_3;
				else
					next_state = DATA_WAIT_NEXT23_2;
			end

			BIT_RECEIVED23_3: //118
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE23_3;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED23_3;
			
			end
			DATA_WRITE23_3: //119
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT23_3;
			end

			DATA_WAIT_NEXT23_3: //120
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0110;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED24;
				else
					next_state = DATA_WAIT_NEXT23_3;
			end

			BIT_RECEIVED24: //121
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE24;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED24;
			
			end
			DATA_WRITE24: //122
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//next_d_status = 4'b0011;
				enable_CRC16 = 0;
				next_state = CRC_CHECK3;
			end

			/*DATA_WAIT_NEXT24: //123
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0111;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = CRC_CHECK3;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT3;
				else
					next_state = DATA_WAIT_NEXT24;
			end*/


			BIT_RECEIVED25: //124
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE25;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED25;
			
			end
			DATA_WRITE25: //125
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				//next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT25;
			end

			DATA_WAIT_NEXT25: //126
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				//if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED26;
				//else
				//	next_state = DATA_WAIT_NEXT25;
			end
			BIT_RECEIVED26: //127
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE26;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED26;
			
			end
			DATA_WRITE26: //128
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT26;
			end

			DATA_WAIT_NEXT26: //129
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED27;
				else
					next_state = DATA_WAIT_NEXT26;
			end
			BIT_RECEIVED27: //130
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE27;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED27;
			
			end
			DATA_WRITE27: //131
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT27;
			end

			DATA_WAIT_NEXT27: //132
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				//if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT3;
				//else if (shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED27_0;
				//else
				//	next_state = DATA_WAIT_NEXT27_0;
			end

			BIT_RECEIVED27_0: //130
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE27_0;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED27_0;
			
			end
			DATA_WRITE27_0: //131
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT27_0;
			end

			DATA_WAIT_NEXT27_0: //132
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				//if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT3;
				//else if (shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED27_1;
				//else
				//	next_state = DATA_WAIT_NEXT27_0;
			end


			BIT_RECEIVED27_1: //130
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE27_1;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED27_1;
			
			end
			DATA_WRITE27_1: //131
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0011;
				enable_CRC16 = 1;
				next_state = DATA_WAIT_NEXT27_1;
			end

			DATA_WAIT_NEXT27_1: //132
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				//if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT3;
				//else if (shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED27_2;
				//else
				//	next_state = DATA_WAIT_NEXT27_1;
			end
			
			BIT_RECEIVED27_2: //130
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE27_2;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED27_2;
			
			end
			DATA_WRITE27_2: //131
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 0;
				next_state = CRC_CHECK4;
			end

			DATA_WAIT_NEXT27_2: //132
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				//if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT3;
				//else if (shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED27_3;
				//else
				//	next_state = DATA_WAIT_NEXT27_2;
			end

			BIT_RECEIVED27_3: //130
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 1;
				if(byte_received == 1'b1)
					next_state = DATA_WRITE27_3;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR3;

				else
					next_state = BIT_RECEIVED27_3;
			
			end
			DATA_WRITE27_3: //131
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b0101;
				enable_CRC16 = 1;
				next_state = CRC_CHECK4;
			end



			CRC_CHECK3: //133
			begin
				enable_CRC16 = 0;
				if (CRC16 == '0)
					next_state = CRC_CHECK4;				
				else
					next_state = EOP_ERR3;
			end
			
			CRC_CHECK4: //134
			begin
				enable_CRC16 = 0;
				next_state = CRC_CHECK4_nxt;
			end					
		
			CRC_CHECK4_nxt: //134
			begin
				enable_CRC16 = 0;
				next_state = EOP_WAIT3;
			end

			EOP_WAIT3: //135
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC16 = 0;
				if(eop == 1'b0) begin
					next_state = WAIT4_0;	
				end
			        //else if(Decode_Instruction == 3'b001)
				//	next_state = WAIT4;
				else
					next_state = EOP_WAIT3;
			end
			WAIT4_0: begin
				next_state = WAIT4_1;
			end
			WAIT4_1: begin
				next_state = WAIT4_2;
			end
			WAIT4_2: begin
				next_state = WAIT4_3;
			end
			WAIT4_3: begin
				next_state = WAIT4_4;
			end
			WAIT4_4: begin
				next_state = WAIT4_5;
			end
			WAIT4_5: begin
				next_state = WAIT4_6;
			end
			WAIT4_6: begin
				next_state = WAIT4;
			end
			EOP_ERR3: //136
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR3;
				else
					next_state = EOP_ERR3;
			end

			ERR3: //137
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(d_edge == 1'b1)
					next_state = RECEIVING3;
			end

//SETUP RECEIVE 2

			WAIT4: //138
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b1010;
				if (Decode_Instruction == '0)
					next_state = IDLE4;
				else
					next_state = WAIT4;
			end

			IDLE4: //139
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
                                if( Decode_Instruction == 3'b101)
                                        next_state = WAIT;
				else if( d_edge == 1'b1 )
					next_state = RECEIVING4;
				//else if(Decode_Instruction == 0)	//added on 12/14
				//	next_state = IDLE;
				else
					next_state = IDLE4;
			end
 
			RECEIVING4: //140
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC4;
				else
					next_state = RECEIVING4;
			end

			CHECK_SYNC4: //141
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH4;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT4;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR4;


			end

			NO_MATCH4: //142
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR4;
				else
				  next_state = NO_MATCH4;
			   
			end

			NO_MATCH_ERROR4: //143
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR4;
				else
					next_state = NO_MATCH_ERROR4;
			end

			MATCH_WAIT4: //144
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;		
				if(shift_enable == 1)
					next_state = BIT_RECEIVED28;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR4;
			end

			BIT_RECEIVED28: //145
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA10;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR4;

				else
					next_state = BIT_RECEIVED28;
			end
			
			CHECK_DATA10: //146
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				if(rcv_data == IN_ID)
					next_state = DATA_WRITE28;
				else if(rcv_data == OUT_ID)
					next_state = DATA_WRITE28;
				else
					next_state = ERR4;
					
			end
			DATA_WRITE28: //147
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT28;
			end

			DATA_WAIT_NEXT28: //148
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED29;
				//else if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT4;
				else
					next_state = DATA_WAIT_NEXT28;
			end
			
			BIT_RECEIVED29: //149
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					//next_state = DATA_WRITE29;
					next_state = CHECK_DATA60;
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED29;
			end
			
			
			CHECK_DATA60: //150
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				if(rcv_data[0] != 0)
					next_state = ERR4;
				else
					next_state = DATA_WRITE29;
			end

			DATA_WRITE29: //151
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT29;
			end

			DATA_WAIT_NEXT29: //152
			begin
				enable_CRC5 = 1;
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED30;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT4;
				else
					next_state = DATA_WAIT_NEXT29;
			end

			BIT_RECEIVED30: //153
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				enable_CRC5 = 1;
				if(byte_received == 1'b1)
					next_state = CHECK_DATA12;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR4;

				else
					next_state = BIT_RECEIVED30;
			end
			
			CHECK_DATA12: //154
			begin
				rcving = 1'b1;
				enable_CRC5 = 0;
				if (CRC5 == '0)
					next_state = DATA_WRITE30;
				else
					next_state = EOP_ERR4;
			end

			DATA_WRITE30: //155
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT30;
			end

			DATA_WAIT_NEXT30: //156
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				//if(shift_enable == 1'b1 && eop == 1'b0)
				//	next_state = BIT_RECEIVED2;
				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT4;
				else
					next_state = DATA_WAIT_NEXT30;
			end
			

			EOP_WAIT4: //157
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(eop == 1'b0)
					next_state = WAIT5;
				else
					next_state = EOP_WAIT4;
			end

			EOP_ERR4: //158
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR4;
				else
					next_state = EOP_ERR4;
			end

			ERR4: //159
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(d_edge == 1'b1)
					next_state = RECEIVING4;
			end
//ACK
			WAIT5: //160
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_d_status = 4'b1011;
				next_state = IDLE5;
			end

			IDLE5: //161
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 )
					next_state = RECEIVING5;
				else
					next_state = IDLE5;
			end
 
			RECEIVING5: //162
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC5;
				else
					next_state = RECEIVING5;
			end

			CHECK_SYNC5: //163
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( rcv_data != SYNC_BYTE )
					next_state = NO_MATCH5;
			
  				if( rcv_data == SYNC_BYTE)
					next_state = MATCH_WAIT5;

				if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_ERR5;


			end

			NO_MATCH5: //164
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR5;
				else
				  next_state = NO_MATCH5;
			   
			end

			NO_MATCH_ERROR5: //165
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR5;
				else
					next_state = NO_MATCH_ERROR5;
			end

			MATCH_WAIT5: //166
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;		
				if(shift_enable == 1 && ((Decode_Instruction == 3'b110) || (Decode_Instruction == 3'b011))) begin
					next_state = WRITE_BIT_RECEIVE1;
                                        next_d_status = 4'b0000;
                                end
			        else if (shift_enable == 1) begin
                                        next_state = BIT_RECEIVED31;
                                end
				if(eop == 1'b1 && shift_enable == 1'b1) begin
					next_state = EOP_ERR5;
                                end
			end

			BIT_RECEIVED31: //167
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = CHECK_DATA13;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR5;

				else
					next_state = BIT_RECEIVED31;
			end
			
			CHECK_DATA13: //168
			begin
				rcving = 1'b1;
				if(rcv_data == ACK_PASS)
				begin
					next_state = DATA_WRITE31;
				end
				else
				begin
					next_state = ERR5;
				end
					
			end
			DATA_WRITE31: //169
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_Success = 1;
				next_state = DATA_WAIT_NEXT31;
			end

			DATA_WAIT_NEXT31: //170
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;
				next_Success = 1;
				//next_d_status = 4'b1000;
				if(shift_enable == 1'b1 && eop == 1'b1) begin
					
					next_state = EOP_WAIT5;
				end
				else
					next_state = DATA_WAIT_NEXT31;
			end
			

			EOP_WAIT5: //171
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(eop == 1'b0 && Success == 1) begin
					next_state = PRE_IDLE4_0;
				end
				else if(eop == 1'b0 && Success == 0) begin
					next_state = PRE_IDLE4_0;	
				end
				else
					next_state = EOP_WAIT5;
			end

			EOP_ERR5: //172
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR5;
				else
					next_state = EOP_ERR5;
			end

			ERR5: //173
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;
				next_d_status = 4'b0100;

				if(d_edge == 1'b1)
					next_state = RECEIVING5;
			end

			PRE_IDLE4_0: begin
				if (Success)
					next_d_status = 4'b1000;
				else
					next_d_status = 4'b1001;
				if(Decode_Instruction == '1)
					next_state = IDLE;
				else
					next_state = PRE_IDLE4_1;
			end
			PRE_IDLE4_1: begin
				if(Decode_Instruction == '1)
					next_state = IDLE;
				else
					next_state = PRE_IDLE4_2;
			end
			PRE_IDLE4_2: begin
				if(Decode_Instruction == '1)
					next_state = IDLE;
				else
					next_state = PRE_IDLE4_3;
			end
			PRE_IDLE4_3: begin
				if(Decode_Instruction == '1)
					next_state = IDLE;
				else
					next_state = IDLE4;
			end
 //WRITE OPERATION
                      WRITE_BIT_RECEIVE1:begin //174
                               rcving = 1'b1;
                               w_enable = 1'b0;
                               r_error = 1'b0;
                               next_d_status = 4'b0000;

				if(byte_received == 1'b1)
					next_state = WRITE_BIT_CHECK1;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR5;

				else
					next_state = WRITE_BIT_RECEIVE1;
                      end   
                      WRITE_BIT_CHECK1:begin //175
                               rcving = 1'b1;
                               next_d_status = 4'b0000;
                               if(rcv_data == DATA1)
				begin
					next_state = WRITE_BIT_WAIT1;
                             		next_d_status = 4'b0000;
				end
				else
				begin
					next_state = ERR5;
					next_d_status = 4'b1001;
				end
	              end	
                       WRITE_BIT_WAIT1:begin //176
                               rcving = 1'b1;
                               w_enable = 1'b0;
                               r_error = 1'b0;
                               enable_CRC16 = 1;
	                             next_d_status = 4'b0000;
				if(shift_enable == 1'b1 && eop == 1'b0) begin
                             next_d_status = 4'b0000;
					next_state = WRITE_BIT_RECEIVE2;
                                end
				else if(shift_enable == 1'b1 && eop == 1'b1) begin
           
					next_state = EOP_WAIT5;
                                end
				else begin
                             next_d_status = 4'b0000;
					next_state = WRITE_BIT_WAIT1;
                                end
                               end
                   WRITE_BIT_RECEIVE2:begin //175
                               rcving = 1'b1;
                               w_enable = 1'b0;
                               r_error = 1'b0;
                               enable_CRC16 = 1;
                               next_d_status = 4'b0001;
                             if(Decode_Instruction == 3'b011) 
                                        next_state = GOBACK;
                                else if(byte_received == 1'b1)
					next_state = WRITE_BIT_WAIT2;
			//	else if(eop == 1'b1 && shift_enable == 1'b1)
			//		next_state = EOP_ERR5;
                                else
					next_state = WRITE_BIT_RECEIVE2;
	                        end
                  /*     WRITE_BIT_CHECK2:begin //175
                               rcving = 1'b1;
                               if(rcv_data == DATA1)
				begin
					next_state = WRITE_BIT_WAIT2;
				end
				else
				begin
					next_state = ERR5;
					next_d_status = 4'b1001;
				end
	              end	
                  */  //totally  
                      WRITE_BIT_WAIT2:begin //dont know
                                enable_CRC16 = 1;
                                w_enable = 1'b1;
                                rcving = 1'b1;
                             next_d_status = 4'b0000;
                                next_state = WRITE_BIT_WAIT3;
                          end
                      WRITE_BIT_WAIT3:begin //176
                               rcving = 1'b1;
                               w_enable = 1'b0;
                               r_error = 1'b0;
                                next_d_status = 4'b0010;
                               enable_CRC16 = 1;
                                if(Decode_Instruction == 3'b011) 
                                        next_state = GOBACK;
				else if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = WRITE_BIT_RECEIVE2;
				//else if(shift_enable == 1'b1 && eop == 1'b1)
				//	next_state = EOP_WAIT5;
				else
					next_state = WRITE_BIT_WAIT3;
                      end
                      GOBACK:begin
                           rcving =1'b1;
                           next_d_status = 4'b1111;
                           enable_CRC16 = 1;
                           next_state = WRITEWAIT1;
                      end
                      WRITEWAIT1: begin
                           rcving =1'b1;
                              enable_CRC16 = 1;
                            if(shift_enable == 1'b1 && eop == 1'b0)
                             next_state = WRITEWAIT2;
                            else
                              next_state = WRITEWAIT1;
                      end
                      WRITEWAIT2: begin
                           rcving =1'b1;
 				  enable_CRC16 = 1;
                          if(shift_enable == 1'b1 && eop == 1'b0)
                             next_state = WRITEWAIT3;
                            else
                              next_state = WRITEWAIT2;
                      end
                      WRITEWAIT3: begin
                           rcving =1'b1;
   				enable_CRC16 = 1;
                          if(shift_enable == 1'b1 && eop == 1'b0)
                             next_state = WRITEWAIT4;
                            else
                              next_state = WRITEWAIT3;
                      end
                      WRITEWAIT4: begin
                           rcving =1'b1;
   				enable_CRC16 = 1;
                          if(shift_enable == 1'b1 && eop == 1'b0)
                             next_state = WRITEWAIT5;
                            else
                              next_state = WRITEWAIT4;
                      end
                      WRITEWAIT5: begin
                            rcving =1'b1;
   				enable_CRC16 = 1;	
                            if(shift_enable == 1'b1 && eop == 1'b0)
                             next_state = WRITEWAIT6;
                            else
                              next_state = WRITEWAIT5;
                      end
                      WRITEWAIT6: begin
                            rcving =1'b1;
   				enable_CRC16 = 1;
                            if(shift_enable == 1'b1 && eop == 1'b0)
                             next_state = DATA_WRITE23_3;
                            else
                              next_state = WRITEWAIT6;
                      end
		endcase
	end

endmodule
