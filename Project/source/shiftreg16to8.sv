// $Id: $
// File name:   shiftreg16to8.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: takes a 16 bits value and outputs two 8 bits value
module shiftreg16to8
(
  input wire shift_enable,
  input wire clk2,
  input wire NReset,
  output wire [7:0] eightbits,
  input wire [15:0] sixteenbits,
  input wire load_enable
);
  reg [16:0] current_output;
  reg [16:0] next_output;
  
assign eightbits = current_output[7:0];

  always_ff @ (posedge clk2, negedge NReset) begin
  if(NReset == 0) begin
    current_output <= 0;
  end 
  else begin 
    current_output <= next_output;
  end
  end
  
  always_comb begin  //input logic
  if(load_enable) begin
   next_output = sixteenbits;
  end    
  else if(shift_enable) begin
   next_output = {8'b00000000, current_output[15:8]};
  end
  else begin 
   next_output = current_output[15:0];
  end
  end

endmodule
