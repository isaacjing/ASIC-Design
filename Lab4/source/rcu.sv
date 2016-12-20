// $Id: $
// File name:   rcu.sv
// Created:     9/20/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Receiver Control Unit for UART
module rcu
(
	input clk,
	input n_rst,
	input start_bit_detected,
	input packet_done,
	input framing_error,
	output reg sbc_clear,
	output reg sbc_enable,
	output reg load_buffer,
	output reg enable_timer
);
reg [3:0] state;
reg [3:0] nextstate;

parameter [3:0] WAITING = 4'b0000,
		DoNothing = 4'b0001,
		SBCClear1 = 4'b0010,
		SBCClear0 = 4'b0011,
		EnableTimer1 = 4'b0100,
		EnableTimer0 = 4'b0101,
		SBCEnable0 = 4'b0110,
		SBCEnable02 = 4'b0111,
		LoadBuffer1 = 4'b1000,
		LoadBuffer0 = 4'b1001;
		
 
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
      sbc_clear = 0;
      sbc_enable = 0;
      load_buffer = 0;
      enable_timer = 0;

      case (state)
      WAITING: begin
	load_buffer = 0;
	if (start_bit_detected == 0)
	  nextstate = WAITING;
	else if (start_bit_detected == 1)
	  nextstate = DoNothing;
      end
      DoNothing: begin
	nextstate = SBCClear1;
      end
      SBCClear1: begin
	load_buffer = 0;
	sbc_clear = 1;
	nextstate = SBCClear0;
      end
      SBCClear0: begin
	load_buffer = 0;
	sbc_clear = 0;
	nextstate = EnableTimer1;
      end
      EnableTimer1: begin
	load_buffer = 0;
	enable_timer = 1;
	if (packet_done == 0)
		nextstate = EnableTimer1;
	else
		nextstate = EnableTimer0;
      end
      EnableTimer0: begin
	load_buffer = 0;
	enable_timer = 0;
	sbc_enable = 1;
	nextstate = SBCEnable0;
      end

      SBCEnable0: begin
	load_buffer = 0;
	sbc_enable = 0;
	if (framing_error == 0)
		nextstate = SBCEnable02;
	else
		nextstate = WAITING;
      end
      SBCEnable02: begin
	load_buffer = 0;
	if (framing_error == 0)
		nextstate = LoadBuffer1;
	else
		nextstate = WAITING;
      end
      LoadBuffer1: begin
	load_buffer = 1;
	nextstate = LoadBuffer0;
      end
      LoadBuffer0: begin
	load_buffer = 0;
	nextstate = WAITING;
      end
      endcase
end
	  
endmodule
