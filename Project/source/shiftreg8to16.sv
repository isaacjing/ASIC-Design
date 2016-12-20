// $Id: $
// File name:   shiftreg8to16.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: shift register that takes two 8 bits value and outputs a 16 bits value.
module shiftreg8to16
(
  input wire shift_enable,
  input wire clk2,
  input wire NReset,
  input wire [7:0] eightbits,
  output wire [15:0] sixteenbits
);
  reg [15:0] current_output;
  reg [15:0] next_output;
  
assign sixteenbits = current_output;

  always_ff @ (posedge clk2, negedge NReset) begin
  if(NReset == 0) begin
    current_output <= 0;
  end 
  else begin 
    current_output <= next_output;
  end
  end
  
  always_comb begin  //input logic
  if(shift_enable) begin
   next_output = {eightbits[7:0], current_output[15:8]};
  end
  else begin
   next_output = current_output[15:0];
  end
  end

endmodule
