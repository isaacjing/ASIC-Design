// $Id: $
// File name:   moore.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: moore.sv 1101 detector
module moore
(
	input wire clk,
	input wire n_rst,
	input wire i,
	output reg o
);
reg [2:0] state;
reg [2:0] nextstate;

parameter [2:0] WAITING = 3'b000,
		RCV1 = 3'b001,
		RCV11 = 3'b010,
		RCV110 = 3'b011,
		RCV1101 = 3'b100;
 
always_ff @ (posedge clk, negedge n_rst)
  begin:StateReg
    if(n_rst == 1'b0)
    begin      
	state <= WAITING;
    end
    else
    begin
      state <= nextstate;
    end
  end

always_comb 
begin: Next_State
      nextstate = state; //DEFAULT STATE
      case (state)
      WAITING: begin
	if (i == 0)
	  nextstate = WAITING;
	else
	  nextstate = RCV1;
      end
      RCV1: begin
	if (i == 0)
	  nextstate = WAITING;
	else
	  nextstate = RCV11;
      end
      RCV11: begin
	if (i == 0)
	  nextstate = RCV110;
	else
	  nextstate = RCV11;
      end
      RCV110: begin
	if (i == 0)
	  nextstate = WAITING;
	else
	  nextstate = RCV1101;
      end
      RCV1101: begin
	if (i == 0)
	  nextstate = WAITING;
	else
	  nextstate = RCV11;
      end
      endcase
end
assign o = (state == RCV1101) ? 1'b1 : 1'b0;
	  
endmodule