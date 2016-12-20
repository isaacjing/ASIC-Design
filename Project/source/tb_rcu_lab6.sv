// $Id: $
// File name:   rcu.sv
// Created:     10/21/2015
// Author:      Shrish Mansey
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: RCU Block for testing only. It handles bit-stuffing.
//
//

module tb_rcu_lab6(
	input wire clk,
	input wire n_rst,
	input wire d_edge,
	input wire eop,
	input wire shift_enable,
	input wire [7:0] rcv_data,
	input wire byte_received,
	output reg rcving,
	output reg w_enable,
	output reg r_error
);

	localparam SYNC_BYTE = 8'b10000000;
	//localparam SYNC_BYTE = 8'b01010100;

	typedef enum logic[3:0] {IDLE, RECEIVING, CHECK_SYNC, MATCH_WAIT, NO_MATCH, NO_MATCH_ERROR, BIT_RECEIVED, DATA_WRITE, DATA_WAIT_NEXT, EOP_ERR, EOP_WAIT, ERR, WAIT} state_type;
	state_type curr_state, next_state;

	always_ff @ (posedge clk, negedge n_rst)
	begin
		if( !n_rst )
		begin
			curr_state <= WAIT;
		end
		else
		begin
			curr_state <= next_state;
		end
	end

	always_comb
	begin
		next_state = curr_state;
		rcving = 1'b0;
		w_enable = 1'b0;
		r_error = 1'b0;
		case(curr_state)

			WAIT:
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				next_state = IDLE;
			end

			IDLE:
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( d_edge == 1'b1 ) begin
					next_state = RECEIVING;
					rcving = 1'b1;
				end
				else
					next_state = IDLE;
			end

			RECEIVING:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if( byte_received == 1'b1 )
					next_state = CHECK_SYNC;
				else
					next_state = RECEIVING;
			end

			CHECK_SYNC:
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

			NO_MATCH:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if( eop == 1'b1 && shift_enable == 1'b1 )
					next_state = NO_MATCH_ERROR;
				else
				  next_state = NO_MATCH;
			   
			end

			NO_MATCH_ERROR:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR;
				else
					next_state = NO_MATCH_ERROR;
			end

			MATCH_WAIT:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

			//	if(byte_received == 0)
			//		next_state = MATCH_WAIT;
				
				if(shift_enable == 1)
					next_state = BIT_RECEIVED;
			   
				if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;
			end

			BIT_RECEIVED:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(byte_received == 1'b1)
					next_state = DATA_WRITE;
				
				else if(eop == 1'b1 && shift_enable == 1'b1)
					next_state = EOP_ERR;

				else
					next_state = BIT_RECEIVED;
			end

			DATA_WRITE:
			begin
				rcving = 1'b1;
				w_enable = 1'b1;
				r_error = 1'b0;

				next_state = DATA_WAIT_NEXT;
			end

			DATA_WAIT_NEXT:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = BIT_RECEIVED;
				else if(shift_enable == 1'b1 && eop == 1'b1)
					next_state = EOP_WAIT;
				else
					next_state = DATA_WAIT_NEXT;
			end

			EOP_WAIT:
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b0;

				if(eop == 1'b0)
					next_state = WAIT;
				else
					next_state = EOP_WAIT;
			end

			EOP_ERR:
			begin
				rcving = 1'b1;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(shift_enable == 1'b1 && eop == 1'b0)
					next_state = ERR;
				else
					next_state = EOP_ERR;
			end

			ERR:
			begin
				rcving = 1'b0;
				w_enable = 1'b0;
				r_error = 1'b1;

				if(d_edge == 1'b1)
					next_state = RECEIVING;
			end
		endcase
	end

endmodule
