// $Id: $
// File name:   outputprocessblock.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: outputprocessblock is a fancy mux that handles where the data from flash will go to. Either to off-chip SRAM, or to RX_FIFO_OUT
// $Id: $

module outputprocessblock
(
  input wire clk2,
  input wire NReset,
  input wire [7:0] FDataOut,
  input wire OPB_outputshift,
  input wire Output_control,
  output wire [7:0] In_SRAM,
  output wire [7:0] Output
);
  reg [7:0] next_data1;
  reg [7:0] next_data2;
  reg [7:0] current_data;
 
assign Output = current_data;
assign next_data1 = Output_control ? 0 : FDataOut;
assign In_SRAM = Output_control ? FDataOut : 0 ;

always_comb
begin
  if(OPB_outputshift == 0)begin
  next_data2 = current_data;
  end
  else begin 
  next_data2 = next_data1;  
  end
end

always_ff @ (posedge clk2, negedge NReset) begin
if(!NReset) begin
   current_data <= 0;
end
else begin
   current_data <= next_data2;
end
end

endmodule

