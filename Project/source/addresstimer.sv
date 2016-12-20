// $Id: $
// File name:   Addresstimer.sv
// Created:     11/5/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Address timer, which counts how many pages within a block. It can counts up to 64
module addresstimer
(
 input wire clk2,
 input wire NReset,
 input wire AddTimer_Ena,
 input wire [5:0] Rollover_Value,
 input wire clear,
 input wire [5:0] startvalue,
 output reg AddTimer_Rollover,
 output wire [5:0] CurrentAdd
);



flex_counter_advanced #(.NUM_CNT_BITS(6),.RESET_BIT(0)) C2( .clk(clk2), .n_rst(NReset), .clear(clear), .count_enable(AddTimer_Ena), .rollover_val(Rollover_Value[5:0]), .count_out(CurrentAdd[5:0]), .rollover_flag(AddTimer_Rollover),.START_BIT(startvalue[5:0]));

endmodule
