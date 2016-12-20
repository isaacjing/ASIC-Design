// $Id: $
// File name:   USBTransmitter.sv
// Created:     11/14/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: USB transmitter wrapper for all USB transmitter blocks.
module USBTransmitter
(
 input wire 	  clk,
 input wire 	  empty,
 output wire 	  D_Plus_Out, 
 output wire 	  D_Minus_Out, 
 input wire 	  N_reset, 
 input wire [3:0] Encode_Instruction,
 input wire [7:0] Snt_data,
 output wire	  W_enable_e,
 output wire [7:0] out_data,
 input wire	  Output_Enable,
 input  wire [7:0] Output_Value,
 output reg r_enable_e,
 output reg [2:0] Encode_Status
 
);
   
reg selection;
reg rollover_val;
reg clear;
reg eop_done;

wire w_enable;
reg d_plus;
reg d_minus;
reg ACK_Enable;

reg output_selection;
reg sending;
reg [7:0] ack;
reg byte_done;

reg bit_ready;
reg d_plus_e;
reg d_minus_e;
reg E_original;
reg e_orig;
reg PTSShift;


reg readClock;
reg writeClock;
reg w_data;
reg r_data;

reg full;
reg freeze;
reg pause;

reg bit_ready2;

reg clear_crc;

reg [15:0] CRC;

reg enable_CRC;

reg D_Plus;
reg D_Minus;
reg D_Plus_Next;
reg D_Minus_Next;
reg load_enable;

assign D_Plus_Out = D_Plus;
assign D_Minus_Out = D_Minus;
assign W_enable_e = (output_selection == 1'b0)? Output_Enable: ACK_Enable;
assign out_data = (output_selection == 1'b0)? Output_Value: ack;
assign w_enable = !empty;

EOP_Generator EOP_GENERATOR(.clk(clk), .n_rst(N_reset), .selection(selection), .clear(clear), .eop_done(eop_done), .d_plus(d_plus), .d_minus(d_minus));

encode ENCODE(.clk(clk), .n_rst(N_reset), .d_plus_e(d_plus_e), .d_minus_e(d_minus_e), .bit_ready2(bit_ready2), .e_orig, .bit_ready, .freeze(freeze));

encode_rcu ENCODE_RCU( .byte_done(byte_done), 
.Encode_Instruction(Encode_Instruction),
.freeze(freeze),
.w_enable(w_enable),
.eop_done(eop_done),
.clk(clk),
.n_rst(N_reset),
.ACK_Enable(ACK_Enable),
.r_enable_e(r_enable_e),
.output_selection(output_selection),
.Encode_Status(Encode_Status),
.sending,
.selection(selection),
.ack(ack), 
.load_enable(load_enable),
.clear_crc(clear_crc),
.enable_CRC(enable_CRC),
.CRC(CRC),
.clear, .bit_ready);



timer_encode TIMER_ENCODE(
	.clk(clk),
	.n_rst(N_reset),
	.clear(clear),
	.pause(pause),
	.bit_ready(bit_ready),
	.byte_done(byte_done), .sending(sending), .PTSShift(PTSShift)
	
);

flex_pts_sr #(8, 0) FLEX_PTS_SR (
	.clk(clk),
	.n_rst(N_reset),
	.shift_enable(PTSShift),
	.load_enable(load_enable),
	.parallel_in(Snt_data),
	.serial_out(E_original)
);



EncodeBTS ENCODEBTS(
	.clk(clk),
	.n_rst(N_reset),
	.E_original(E_original),
	.bit_ready(bit_ready),
	.bit_ready2(bit_ready2),
	.E_orig(e_orig),
	.pause(pause)
);


CRC16Generator CRC16Generator(
.D_Plus_sync(E_original),
.enable_CRC16(enable_CRC),
.CLEAR(clear_crc),
.CRC16(CRC),
.shift_enable(PTSShift),
.clk(clk),
.n_rst(N_reset)
);


always_ff @ (posedge clk, negedge N_reset) begin
   if(N_reset == 1'b0) begin
      D_Plus <= 1;
      D_Minus <= 0;
   end
   else begin
      D_Plus <= D_Plus_Next;
      D_Minus <= D_Minus_Next;
   end
end

always_comb begin
   D_Plus_Next = (selection == 1'b0)? d_plus_e: d_plus;
   D_Minus_Next = (selection == 1'b0)? d_minus_e: d_minus;
end

endmodule

