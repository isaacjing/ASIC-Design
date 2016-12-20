// $Id: $
// File name:   EOP_Generator.sv
// Created:     11/7/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: EOP generator block, which generates 16 clock cycle of d_plus = 0, d_minus = 0 following by 8 clock cycles of d_plus = 1 and d_minus = 1;
module EOP_Generator
(
	input wire clk,
	input wire n_rst,
	input wire selection,
	input wire clear,
	output wire eop_done,
	output wire d_plus,
	output wire d_minus
);
reg[3:0] cout_out;
reg rollover_flag;
reg dplus;
reg dminus;
reg enable;
reg eopdone;

flex_counter #(4) count_8
(.clk(clk), .n_rst(n_rst), .clear(clear),
 .count_enable(enable), .rollover_val(4'd7),
 .count_out(cout_out), .rollover_flag(rollover_flag));

assign eop_done=eopdone;
assign d_plus = dplus;
assign d_minus = dminus;
reg [3:0] state;
reg [3:0] nextstate;

parameter [3:0] RESET = 4'd0,
		FIRSTEIGHT = 4'd1,
		SECONDEIGHT = 4'd2,
		THIRDEIGHT = 4'd3, 
		DONE = 4'd4;
 
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
	nextstate = state;
	dplus = 0;
	dminus = 0;
	enable = 1;
	eopdone = 0;
	case (state)
	RESET: begin
		dplus = 0;
		dminus = 0;
		if (selection & rollover_flag)
			nextstate = SECONDEIGHT;
		else if (selection) begin
			nextstate = RESET;
			enable = 1;
		end
		else begin
			enable = 0;
			nextstate = RESET;
		end
	end
	SECONDEIGHT: begin	
		dplus = 0;
		dminus = 0;
		enable = 1;
		if (rollover_flag)
			nextstate = THIRDEIGHT;
		else
			nextstate = SECONDEIGHT;
	end
	THIRDEIGHT: begin	
		dplus = 1;
		dminus = 0;
		enable = 1;
		if (rollover_flag) begin
			eopdone = 1;
			nextstate = DONE;
		end
		else
			nextstate = THIRDEIGHT;
	end
	DONE: begin
		dplus = 1;
		dminus = 0;
		enable = 0;
		eopdone = 0;
		nextstate = RESET;
	end
endcase
end
endmodule



