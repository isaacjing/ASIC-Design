// $Id: $
// File name:   flex_stp_sr.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: flex_stp_sr.sv
module flex_pts_sr
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1
 )
(
	input wire clk,
	input wire n_rst,
	input wire shift_enable,
	input wire load_enable,
	input wire [NUM_BITS - 1:0] parallel_in,
	output wire serial_out

);
  reg temp;
  reg [NUM_BITS - 1:0] InputCopy;
  reg [NUM_BITS - 1:0] InputCopy_nxt;
  
  always_ff @ (posedge clk, negedge n_rst)
  begin
    if(n_rst == 1'b0)
    begin      
      InputCopy <= '1;//Clear the output
    end
    else
    begin
      InputCopy <= InputCopy_nxt;
    end

  end

  always_comb
  begin
    InputCopy_nxt = InputCopy;
    
    //Actual Shift
    if (SHIFT_MSB == 1'b0 && shift_enable == 1'b1 && load_enable == 1'b0)
    begin
      InputCopy_nxt = {1'b0, InputCopy[NUM_BITS - 1 : 1]};
    end
      
    if (SHIFT_MSB == 1'b1 && shift_enable == 1'b1 && load_enable == 1'b0)
    begin
      InputCopy_nxt = {InputCopy[NUM_BITS - 2:0], 1'b0};
    end
    
    if(load_enable == 1'b1)
    begin
      InputCopy_nxt = parallel_in;	//LOAD THE SIGNAL
    end
    else
    begin
      InputCopy_nxt = InputCopy_nxt;//Normal operation
    end
end

  always_comb
  begin
    temp = 1;
        //Actual output
    if(SHIFT_MSB == 0)
    begin
      temp = InputCopy[0];
    end
    else if(SHIFT_MSB == 1)
    begin
      temp = InputCopy[NUM_BITS - 1];
    end
  end

assign serial_out = temp;
	  
endmodule