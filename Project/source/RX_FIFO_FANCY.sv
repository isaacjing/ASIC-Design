// $Id: $
// File name:   RX_FIFO.sv
// Created:     11/2/2015/
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: RX_FIFO.sv, obsolete FIFO.
module RX_FIFO_FANCY
#(
	parameter NUM_BYTES = 64,
	parameter ADDRESS_WIDTH = NUM_BYTES >> 1
 )
(
	input wire readClock,
	input wire writeClock,
	input wire n_rst,
	input wire r_enable,
	input wire w_enable,
	input wire [7:0] w_data,
	output reg [7:0] r_data,
	output wire empty,
	output wire full
);
  reg [7:0] Memory [NUM_BYTES - 1 : 0];
  wire [ADDRESS_WIDTH - 1 : 0] pNextWordWrite;
  wire [ADDRESS_WIDTH - 1 : 0] pNextWordRead;
  wire [ADDRESS_WIDTH - 1 : 0] SIZE;
  reg [7:0] r_data_nxt;
  wire NextWriteAddressEnable;
  wire NextReadAddressEnable;
  reg [7:0] Input;
  reg [7:0] Output;
  //Input = w_data;
//Data in and data out logic:
  always_ff @ (posedge readClock)
  begin
    if(r_enable && !empty) begin
	Output <= Memory[pNextWordRead];
    end
  end
  
  always_ff @ (posedge writeClock)
  begin
    if(w_enable && !full) begin
	Memory[pNextWordWrite] <= w_data;
    end
  end
  
  always_ff @ (posedge writeClock, negedge n_rst)
  begin
    if(n_rst == 1'b0)	//Reset
    begin
      r_data <= 'z;
    end
    else		//If not reset
    begin
      r_data <= r_data_nxt;
    end
  end

  assign r_data_nxt = Output;
  assign SIZE = NUM_BYTES - 1;
  
//Address controlling:
  assign NextWriteAddressEnable = w_enable & ~full;
  assign NextReadAddressEnable = r_enable & ~empty;
  
  flex_counter_0 #(ADDRESS_WIDTH) WriteAddress(.clk(writeClock), .n_rst(n_rst), .clear(1'b0), .count_enable(NextWriteAddressEnable), 
					       .rollover_val(SIZE + 1'b1), .count_out(pNextWordWrite),
					       .rollover_flag());
  flex_counter_0 #(ADDRESS_WIDTH) ReadAddress (.clk(readClock), .n_rst(n_rst), .clear(1'b0), .count_enable(NextReadAddressEnable),
					       .rollover_val(SIZE + 1'b1), .count_out(pNextWordRead), .rollover_flag());

  assign full = ((pNextWordRead - pNextWordWrite) == 1) | (pNextWordRead == 0 & pNextWordWrite == NUM_BYTES - 1) | (pNextWordRead == 0 & pNextWordWrite == NUM_BYTES - 1) | (pNextWordRead == 1 & pNextWordWrite == NUM_BYTES );
  assign empty = ~full & (pNextWordWrite == pNextWordRead);

endmodule
