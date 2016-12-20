// $Id: $
// File name:   OSCUcounter.sv
// Created:     12/6/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Obsolete wrapper file for OSCU counter. The counter directly exists in OSCU now.

module OSCUcounter
(
 input wire clk2,
 input wire NReset,
 input wire AddTimer_Ena,
 input wire [6:0] Rollover_Value,
 input wire clear,
 input wire [6:0] startvalue,
 output reg AddTimer_Rollover,
 output wire [6:0] CurrentAdd
);



flex_counter_advanced #(.NUM_CNT_BITS(7),.RESET_BIT(0)) C2( .clk(clk2), .n_rst(NReset), .clear(clear), .count_enable(AddTimer_Ena), .rollover_val(Rollover_Value[6:0]), .count_out(CurrentAdd[6:0]), .rollover_flag(AddTimer_Rollover),.START_BIT(startvalue[6:0]));

endmodule
