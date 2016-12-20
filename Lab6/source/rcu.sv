// $Id: $
// File name:   rcu.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Controller unit for USB 1.0 receiver

module rcu
(
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
reg [3:0] state;
reg [3:0] nextstate;

parameter [3:0] RESET = 4'd0,
		SETTOZERO = 4'd1,
		WAITING = 4'd2,
		IDLE = 4'd3,
		BEGINRECEIVING = 4'd4,
		CHECKINGSYNC = 4'd5,
		AWAITINGNEXT = 4'd6,
		FIRSTBITRECEIVED = 4'd7,
		DATARECEIVED = 4'd8,
		DATARECEIVEDNEXT = 4'd9,
		ERROREOP = 4'd10,
		ERROR = 4'd11,
		ERROR2 = 4'd12,
		EIDLE = 4'd13,
		WAITINGEOP = 4'd14;
 
always_ff @ (posedge clk, negedge n_rst)
  begin:StateReg
    if(n_rst == 1'b0)
    begin      
		state <= RESET;
    end
    else
    begin
		state <= nextstate;
    end
  end

always_comb 
begin: Next_State
	nextstate = state; //DEFAULT STATE
	rcving = 0;
	w_enable = 0;
	r_error = 0;
	case (state)
	RESET: begin
		rcving = 0;
		if (!eop) begin
			nextstate = SETTOZERO;
		end
    end
	SETTOZERO: begin
		w_enable = 0;
		r_error = 0;
		//nextstate = WAITING;
		nextstate = IDLE;
	end
	WAITING: begin	
		nextstate = IDLE;
	end
	IDLE: begin
		rcving = 0;
		if (d_edge == 1) begin
			nextstate = BEGINRECEIVING;
		end
	end
    BEGINRECEIVING: begin
		rcving = 1;
		r_error = 0;
		if (byte_received == 1) begin
			nextstate = CHECKINGSYNC;
		end
	end
	CHECKINGSYNC: begin
		rcving = 1;
		if (rcv_data == 8'b10000000) begin
			nextstate = AWAITINGNEXT;
		end
		else if (eop & shift_enable)
			nextstate = ERROREOP;
		else
			nextstate = ERROR;
	end
	AWAITINGNEXT: begin
		rcving = 1;
		if (byte_received == 0) begin
			nextstate = AWAITINGNEXT;
		end
		if (shift_enable == 1) begin
			nextstate = FIRSTBITRECEIVED;
		end
	end
	FIRSTBITRECEIVED: begin
		rcving = 1;
		if (eop == 1 & shift_enable == 1) begin
			nextstate = ERROREOP;
		end
		else if (byte_received == 1) begin
			nextstate = DATARECEIVED;
		end
		else
			nextstate = FIRSTBITRECEIVED;
	end
	DATARECEIVED: begin
		rcving = 1;
		w_enable = 1;
		nextstate = DATARECEIVEDNEXT;
	end
	
	DATARECEIVEDNEXT: begin
		rcving = 1;
		w_enable = 0;
		if (shift_enable == 1 & eop == 1) begin
			nextstate = WAITINGEOP;
		end
		else if (shift_enable == 1 & eop == 0) begin
			nextstate = FIRSTBITRECEIVED;
		end
		else
			nextstate = DATARECEIVEDNEXT;
	end
	
	ERROREOP: begin
		rcving = 1;
		r_error = 1;
		if (!eop & shift_enable) begin
			nextstate = EIDLE;
		end
		else
			nextstate = ERROREOP;
	end
	
	ERROR: begin
		rcving = 1;
		r_error = 1;
		if (shift_enable == 1 & eop == 1) begin
			nextstate = ERROR2;
		end
		else
			nextstate = ERROR;
	end
	
	ERROR2: begin
		rcving = 1;
		r_error = 1;
		if (shift_enable == 1 & eop == 0) begin
			nextstate = EIDLE;
		end
		else
			nextstate = ERROR2;
	end
	
	EIDLE: begin
		r_error = 1;
		rcving = 0;
		if (d_edge == 1) begin
			nextstate = BEGINRECEIVING;
		end
    
	end
	WAITINGEOP: begin
		rcving = 0;
		if (!eop) begin
			nextstate = WAITING;
		end
		else
			nextstate = WAITINGEOP;
	
	end
endcase
end
endmodule
