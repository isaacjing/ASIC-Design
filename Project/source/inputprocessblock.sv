// $Id: $
// File name:   inputprocessblock.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Handles data flow into the flash. Data can come from SRAM, or FIFO, or even FCU
module inputprocessblock
(
  input wire clk2,
  input wire NReset,
  input wire [7:0] Command,
  input wire [7:0] Address,
  input wire [7:0] Input,
  input wire [7:0] Out_SRAM,
  input wire [2:0] IPBCommand,
  input wire input_shift,
  output reg [7:0] FDataIn
);
  reg [7:0] select1;
  reg [7:0] current_N_input;
  reg [7:0] next_N_input;
  reg [7:0] next_FDataIn;
  reg [7:0] FDataInternal;
 
assign select1 = IPBCommand[2] ? 0 : (IPBCommand[1] ? (IPBCommand[0] ? Input : Address) : (IPBCommand[0] ? Out_SRAM : '0));
assign FDataInternal = IPBCommand[2] ? Command : (IPBCommand[1:0] == 2'b01 ? select1: current_N_input);

always_comb
begin
  next_FDataIn = FDataInternal;
  if(input_shift)begin
  next_N_input = current_N_input;
  end
  else begin 
  next_N_input = select1;  
  end
end

always_ff @ (posedge clk2, negedge NReset) begin
if(!NReset) begin
   current_N_input <= 0;
   FDataIn <= '0;
end
else begin
   current_N_input <= next_N_input;
   FDataIn <= next_FDataIn;
end
end

endmodule


