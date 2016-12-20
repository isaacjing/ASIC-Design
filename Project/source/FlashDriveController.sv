// $Id: $
// File name:   flashmemorycontroller.sv
// Created:     11/15/2015
// Author:      Jiangshan Jing, Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: wrapper file for the entire flash memory controller.
module FlashDriveController
(
 input wire clk1, 
 input wire clk2,
 input wire NReset,
 input wire Plus_in,
 input wire Minus_in,
 output wire Plus_out,
 output wire Minus_out,
 output wire USBOE,
 output wire FDataOE,
 output wire ALE,
 output wire CLE,
 output wire CE_n,
 output wire RE_n,
 output wire WE_n,
 output wire [7:0] FDataIn,
 input wire [7:0] FDataOut,
 input wire RB,
 output wire WP_n,
 output reg [16:0] OFAdd,
 input wire [15:0] OFDatain,
 output reg OFRead,
 output wire OFWrite,
 output wire [15:0] OFDataout,
 output wire OSRead,
 output wire OSWrite,
 output wire [15:0] OSDataout,
 input wire [15:0] OSDatain,
 output wire [11:0] OSAdd
);
  
reg [2:0] Status;
//reg InputShift;
//reg OutputShift;
//reg [7:0] Output;
reg [7:0] Input;
reg [7:0] Address;
reg [3:0] Request;
reg Full;
reg Input_Enable;
reg Output_Enable;
reg [7:0] Output_Value;
reg [7:0] Snt_data;
wire empty;
reg W_enable_e;
reg R_enable_e;
reg [7:0] Out_Data;
reg [7:0] Rcv_Data;
reg W_enable_d;
reg Full_in;

flashmemorycontroller FlashMemoryController(
.clk2(clk2), 
.NReset(NReset),
.Status(Status),
.RE_n(RE_n),
.WE_n(WE_n),
.ALE(ALE),
.CLE(CLE),
.CE_n(CE_n),
.InputShift(Input_Enable),
.OutputShift(Output_Enable),
//.Output(Output),
.FDataIn(FDataIn),
.FDataOE(FDataOE),
.FDataOut(FDataOut),
.RB(RB),
.Address(Address),
.Input(Input),
.Request(Request),
.Full(Full), // fcu in
.OFAdd(OFAdd),
.OFDatain(OFDatain),
.OFRead(OFRead),
.OFWrite(OFWrite),
.OFDataout(OFDataout),
.WP_n(WP_n),
.Output(Output_Value),
.OSAdd(OSAdd),
.OSRead(OSRead),
.OSWrite(OSWrite),
.OSDataout(OSDataout),
.OSDatain(OSDatain)
);

USBTransceiver USBTransceiver(
.clk(clk1),
.n_rst(NReset),
.Input_Enable(Input_Enable),
.Output_Enable(Output_Enable),
.Output_Value(Output_Value),
.Snt_data(Snt_data),
.empty(empty),
.Status(Status),
.W_enable_e(W_enable_e),
.R_enable_e(R_enable_e),
.Out_Data(Out_Data),
.Address(Address),
.Rcv_data(Rcv_Data),
.Request(Request),
.D_Minus_in(Minus_in),
.D_Plus_in(Plus_in),
.D_Plus_out(Plus_out),
.D_Minus_out(Minus_out),
.W_enable_d(W_enable_d),
.USBOE(USBOE)
);

rx_fifo RX_FIFO_OUT (
.r_clk(clk1), .w_clk(clk2), .n_rst(NReset),
.r_enable(R_enable_e), 
.w_enable(W_enable_e), 
.r_data(Snt_data), 
.w_data(Out_Data), 
.empty(empty), 
.full(Full));

rx_fifo RX_FIFO_IN (
.r_clk(clk2), .w_clk(clk1), .n_rst(NReset), 
.r_enable(Input_Enable), 
.w_enable(W_enable_d), 
.r_data(Input), .w_data(Rcv_Data), .empty(), .full(Full_in));

endmodule

 
 
