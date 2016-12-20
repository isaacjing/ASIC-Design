// $Id: $
// File name:   controller.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Controller unit for the FIR filtering

// Reg Distribution Table
// Reg[0]: Output; 
// Reg[1]: Data4; //Oldest Data
// Reg[2]: Data3; 
// Reg[3]: Data2; 
// Reg[4]: Data1; //Newest Data
// Reg[5]: Temporary location to store Data1
// Reg[6]: F3
// Reg[7]: F2
// Reg[8]: F1
// Reg[9]: F0

`timescale 1ns/10ps
module controller
(
	input wire clk,
	input wire n_reset,
	input wire dr,
	input wire lc,
	input wire overflow,
	output reg cnt_up,
	output reg clear,
	output reg modwait,
	output reg [2:0] op,
	output reg [3:0] src1,
	output reg [3:0] src2,
	output reg [3:0] dest,
	output reg err
);
reg [5:0] state;
reg [5:0] nextstate;
reg modwait_nxt;
reg err_nxt;

parameter [5:0] IDLE = 6'd0,
		STOREF0 = 6'd1,
		STOREF0NEXT = 6'd2,
		STOREF1 = 6'd3,
		STOREF1NEXT = 6'd4,
		STOREF2 = 6'd5,
		STOREF2NEXT = 6'd6,
		STOREF3 = 6'd7,
		STOREDATA = 6'd8,
		ZERO = 6'd9,
		SORT1 = 6'd10,
		SORT2 = 6'd11,
		SORT3 = 6'd12,
		SORT4 = 6'd13,
		MUL1 = 6'd14,
		ADD1 = 6'd15,
		MUL2 = 6'd16,
		SUB1 = 6'd17,
		MUL3 = 6'd18,
		ADD2 = 6'd19,
		MUL4 = 6'd20,
		SUB2 = 6'd21,
		EIDLE = 6'd22,
		READ = 6'd23,
		READ2 = 6'd24,
		READ3 = 6'd25,
		DONOTHING1 = 6'd26,
		DONOTHING2 = 6'd27,
		DONOTHING3 = 6'd28,
		DONOTHING4 = 6'd29,
		DONOTHING5 = 6'd30,
		DONOTHING6 = 6'd31,
		DONOTHING7 = 6'd32,
		DONOTHING8 = 6'd33;
 
always_ff @ (posedge clk, negedge n_reset)
  begin:StateReg
    if(n_reset == 1'b0)
    begin      
		state <= IDLE;
		modwait <= 0;
		err <= 0;
    end
    else
    begin
	state <= nextstate;
	modwait <= modwait_nxt;
	err <= err_nxt;
    end
  end

always_comb 
begin: Next_State
	nextstate = state; //DEFAULT STATE
	cnt_up = 0;
	clear = 0;
	modwait_nxt = 1;
	op = '0;
	src1 = '1;
	src2 = '1;
	dest = '1;
	err_nxt = 0;
	case (state)
	IDLE: begin
		op = '0;
		modwait_nxt = 0;
		//clear = 1;
		if (dr == 0 && lc != 1)
	  		nextstate = IDLE;
		else if (dr == 1) begin
	  		nextstate = STOREDATA;
			modwait_nxt = 1;
		end
		else if (lc == 1) begin
			nextstate = STOREF0;
			modwait_nxt = 1;
		end
      	end
	STOREF0: begin
		clear = 1;
		dest = 4'd9;
		op = 3'b011;
		modwait_nxt = 0;	
		nextstate = STOREF0NEXT;
	end
	STOREF0NEXT: begin
		op = '0;
		modwait_nxt = 0;
		clear = 0;
		if (lc == 1) begin
			nextstate = STOREF1;
			modwait_nxt = 1;
		end
		else
			nextstate = STOREF0NEXT;
	end
    	STOREF1: begin
		modwait_nxt = 0;
		dest = 4'd8;
		op = 3'b011;
		
		nextstate = STOREF1NEXT;
	end
	STOREF1NEXT: begin
		op = '0;
		modwait_nxt = 0;
		if (lc == 1) begin
			nextstate = STOREF2;
			modwait_nxt = 1;
		end		
		else
			nextstate = STOREF1NEXT;
	end
	STOREF2: begin
		dest = 4'd7;
		op = 3'b011;
		modwait_nxt = 0;
		nextstate = STOREF2NEXT;
	end
	STOREF2NEXT: begin
		op = '0;
		modwait_nxt = 0;
		if (lc == 1) begin
			nextstate = STOREF3;
			modwait_nxt = 1;
		end
		else
			nextstate = STOREF2NEXT;
	end
	STOREF3: begin
		dest = 4'd6;
		op = 3'b011;
		modwait_nxt = 0;
		nextstate = IDLE;
	end
	
	STOREDATA: begin
		clear = 0;
		dest = 4'd5;
		op = 3'b010;
		err_nxt = 0;
		modwait_nxt = 1;

		if (dr == 0) begin
			err_nxt = 1;
			modwait_nxt = 0;
			nextstate = EIDLE;
		end
		else
			nextstate = ZERO;
	end
	
	ZERO: begin
		cnt_up = 1;
		src1 = '0;
		src2 = '0;
		dest = '0;
		op = 3'b101;
		nextstate = SORT1;
	end
	
	SORT1: begin
		cnt_up = 0;
		dest = 4'd1;
		src1 = 4'd2;
		op = 3'b001;
		nextstate = SORT2;
	end
	
	SORT2: begin
		dest = 4'd2;
		src1 = 4'd3;
		op = 3'b001;
		nextstate = SORT3;
	end
	
	SORT3: begin
		dest = 4'd3;
		src1 = 4'd4;
		op = 3'b001;
		nextstate = SORT4;
	end
	
	SORT4: begin
		dest = 4'd4;
		src1 = 4'd5;
		op = 3'b001;
		nextstate = MUL1;
	end
	
	MUL1: begin
		dest = 4'd10;
		src1 = 4'd1;
		src2 = 4'd6;
		op = 3'b110;
		if (overflow == 1) begin
			nextstate = EIDLE;
			//err_nxt = 1;
			//modwait_nxt = 0;
		end
		else
			nextstate = ADD1;
	end
	
	ADD1: begin
		dest = '0;
		src1 = '0;
		src2 = 4'd10;
		op = 3'b100;
		if (overflow == 1) begin
			nextstate = EIDLE;
			err_nxt = 1;
			modwait_nxt = 0;
		end
		else
			nextstate = MUL2;
	end
	
	MUL2: begin
		dest = 4'd10;
		src1 = 4'd2;
		src2 = 4'd7;
		op = 3'b110;
		if (overflow == 1) begin
			nextstate = EIDLE;
			//err_nxt = 1;
			//modwait_nxt = 0;
		end
		else
			nextstate = SUB1;
	end
	
	SUB1: begin
		dest = '0;
		src1 = '0;
		src2 = 4'd10;
		op = 3'b101;

		if (overflow == 1) begin
			nextstate = EIDLE;
			err_nxt = 1;
			modwait_nxt = 0;
		end
		else
			nextstate = MUL3;
	end
	
	MUL3: begin
		dest = 4'd10;
		src1 = 4'd3;
		src2 = 4'd8;
		op = 3'b110;
		nextstate = EIDLE;
		if (overflow == 1) begin
			nextstate = EIDLE;
			//err_nxt = 1;
			//modwait_nxt = 0;
		end
		else
			nextstate = ADD2;
	end
	
	ADD2: begin
		dest = '0;
		src1 = '0;
		src2 = 4'd10;
		op = 3'b100;
		if (overflow == 1) begin
			nextstate = EIDLE;
			err_nxt = 1;
			modwait_nxt = 0;
		end
		else
			nextstate = MUL4;
	end
	
	MUL4: begin
		dest = 4'd10;
		src1 = 4'd4;
		src2 = 4'd9;
		op = 3'b110;
		if (overflow == 1) begin
			nextstate = EIDLE;
			//err_nxt = 1;
			//modwait_nxt = 0;
		end
		else
			nextstate = SUB2;
	end
	
	SUB2: begin
		dest = '0;
		src1 = '0;
		src2 = 4'd10;
		op = 3'b101;
		if (overflow == 1) begin
			nextstate = EIDLE;
			err_nxt = 1;
			modwait_nxt = 0;
		end
		else begin
			modwait_nxt = 1;
			nextstate = READ;
		end
	end
	
	EIDLE: begin
		err_nxt = 1;
		modwait_nxt = 0;
		
		if (dr == 0)
			nextstate = EIDLE;
		else begin
			nextstate = STOREDATA;
			modwait_nxt = 1;
		end
	end
	READ: begin
		op = '0;
		nextstate = READ2;
		modwait_nxt = 1;
	end
	READ2: begin
		op = '0;
		nextstate = READ3;
		modwait_nxt = 0;
	end
	READ3: begin
		op = '0;
		nextstate = IDLE;
		modwait_nxt = 0;
	end
	DONOTHING1: begin
		op = '0;
		nextstate = STOREF0NEXT;
	end
	DONOTHING2: begin
		op = '0;
		nextstate = DONOTHING3;
	end
	DONOTHING3: begin
		op = '0;
		nextstate = STOREF1NEXT;
	end
	DONOTHING4: begin
		op = '0;
		nextstate = DONOTHING5;
	end
	DONOTHING5: begin
		op = '0;
		nextstate = STOREF2NEXT;
	end
	DONOTHING6: begin
		op = '0;
		nextstate = DONOTHING7;
	end
	DONOTHING7: begin
		op = '0;
		nextstate = IDLE;
	end

    endcase
	
end

//assign modwait = modwait;

endmodule
