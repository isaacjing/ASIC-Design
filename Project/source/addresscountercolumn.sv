// $Id: $
// File name:   Addtimer.sv
// Created:     11/5/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Address counter, which counts how many bytes within a page. It can counts up to 2112
module addresscountercolumn
(
 input wire clk2,
 input wire NReset,
 input wire ACC_Enable,
 input wire [11:0] End_address,
 input wire clear,
 output reg ADDReached
);
wire [11:0] countout;


flex_counter_advanced #(.NUM_CNT_BITS(12), .RESET_BIT(0)) C1( .clk(clk2), .n_rst(NReset), .clear(clear), .count_enable(ACC_Enable), .rollover_val(End_address), .count_out(countout), .rollover_flag(ADDReached), .START_BIT(12'd0));


endmodule
