// $Id: $
// File name:   USBTranceiver.sv
// Created:     11/29/2015
// Author:      Adit Ghosh
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: USB main wrapper for both USB receiver and USB transmitter.
module USBTransceiver(
input wire clk,
input wire n_rst,
input wire Input_Enable,
input wire Output_Enable,
input wire [7:0] Output_Value,
input wire [7:0]Snt_data,
input wire empty,
input wire [2:0] Status,
output reg W_enable_e,
output reg R_enable_e,
output reg [7:0] Out_Data,
output reg [7:0] Address,
output reg [7:0] Rcv_data,
output wire [3:0] Request,
input wire D_Minus_in,
input wire D_Plus_in,
output wire D_Plus_out,
output wire D_Minus_out,
output wire W_enable_d,
output reg USBOE
);

wire [15:0] CRC16;
wire [4:0] CRC5;
wire R_error;
reg [3:0] Decode_Status;
reg [2:0] Encode_Status;
reg eop;
reg ack_enable;
reg [3:0] Encode_Instruction;
reg ClearCRC;
reg enable_CRC16;
reg enable_CRC5;
reg shift_enable1;
reg [2:0] Decode_Instruction;
wire D_orig;


USBTransmitter USBTRANSMITTER(
.clk(clk),
.empty(empty),
.D_Plus_Out(D_Plus_out), 
.D_Minus_Out(D_Minus_out), 
.N_reset(n_rst), 
.Snt_data(Snt_data),
.W_enable_e(W_enable_e),
.out_data(Out_Data),
.Output_Enable(Output_Enable),
.Output_Value(Output_Value),
.r_enable_e(R_enable_e),
.Encode_Instruction(Encode_Instruction),
.Encode_Status(Encode_Status)
);

usb_receiver USBRECEIVE( 
.clk(clk), 
.n_rst(n_rst), 
.d_plus(D_Plus_in), 
.d_minus(D_Minus_in), 
.r_enable(Input_Enable), 
.Restart(Restart),
.rcv_data(Rcv_data), 
.full(), 
.empty(), 
.rcving(), 
.r_error(R_error), 
.d_status(Decode_Status), 
.w_enable_d(W_enable_d),
.enable_CRC5(enable_CRC5),
.enable_CRC16(enable_CRC16),
.shift_enable1(shift_enable1),
.D_orig(D_orig),
.ClearCRC(ClearCRC), 
.CRC5(CRC5),
.CRC16(CRC16),
.Decode_Instruction(Decode_Instruction)
);



MainRCU MAINRCU(
.clk(clk),
.Restart(Restart),
.n_rst(n_rst),
.Rcv_data(Rcv_data),
.R_error(R_error),
.StatusIn(Status),
.Decode_Status(Decode_Status),
.Encode_Status(Encode_Status),
.eop(eop), 
.Address(Address),
.Request(Request),
.Encode_Instruction(Encode_Instruction),
.USBOE(USBOE),
.Decode_Instruction(Decode_Instruction)
);

CRCGenerator CRCGenerator(.clk(clk), .D_plus_sync(D_orig), .shift_enable(shift_enable1), .enable_CRC5(enable_CRC5), .enable_CRC16(enable_CRC16), .CLEAR(ClearCRC), .CRC5(CRC5), .CRC16(CRC16), .n_rst(n_rst));

endmodule
