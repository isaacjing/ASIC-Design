// $Id: $
// File name:   tb_USB_Transmitter.sv
// Created:     11/2/2015
// Author:      Jing, Jiangshan
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: tb_USB_Transmitter test bench for USB transmitter, obsolete now

`timescale 1ns / 10ps

module tb_USBTransmitter();

	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIODUSB	= 10;
    localparam      CLK_PERIODFCU = 20;
	
	// Shared Test Variables
	reg tb_clk_usb;
	reg tb_clk_fcu;
	
	// Clock generation block
	always
	begin
		tb_clk_usb = 1'b0;
		#(CLK_PERIODUSB/2.0);
		tb_clk_usb = 1'b1;
		#(CLK_PERIODUSB/2.0);
	end

	always
	begin
		tb_clk_fcu = 1'b0;
		#(CLK_PERIODFCU/2.0);
		tb_clk_fcu = 1'b1;
		#(CLK_PERIODFCU/2.0);
	end	

	reg [7:0] Snt_data;
	reg D_Plus_Out;  //output D_Plus
	reg D_Minus_Out; //output D_Minus
	reg Reset; //Reset
	
	//Variables reserved for RX_FIFO_OUT
	reg [7:0] Input; //Input data to RX_FIFO_OUT
	reg ReadFlag;  //Read flag for RX FIFO OUT
	reg WriteFlag; //Write flag for RX FIFO OUT
	reg EmptyFlag; //Empty flag for RX FIFO OUT
	reg Full;	   //Full flag for RX FIFO OUT
	int TC;		   //Test case number
	reg w_enable_e;
	reg [7:0] Input_FIFO;

	reg Output_Selection;
	
	RX_FIFO #(.NUM_BYTES(8)) RX_FIFO_OUT (.readClock(tb_clk_usb), .writeClock(tb_clk_fcu), .n_rst(Reset), .r_enable(ReadFlag), .w_enable(w_enable_e), .r_data(Snt_data), .w_data(Input_FIFO), .empty(EmptyFlag), .full(Full));
	
	USBTransmitter USBTransmitter(.clk(tb_clk_usb), .empty(EmptyFlag), .D_Plus_Out(D_Plus_Out), .D_Minus_Out(D_Minus_Out), .N_reset(Reset), .Snt_data(Snt_data), .out_data(Input_FIFO), .w_enable_e(w_enable_e), .output_enable(WriteFlag), .output_val(Input), .r_enable_e(ReadFlag));
	
	//Format of data:
	/*
		The data will be put on FIFO. The USB transmitter will send the data out.
		We're using Inverted NRZI encoding, in which 0 is represented as a change in the output level, and 1 is represented with no change in state.
		For example:
		If the data put in FIFO is 00101010, the output on D_Plus should be 1(IDLE)->00110010 (Remember, LSB first!)
	*/
	initial
	begin
	//TEST CASE 1
	TC = 1;
	Reset = 0;
	@(negedge tb_clk_fcu);
	@(posedge tb_clk_fcu);
	#1
	Reset = 1;
	@(negedge tb_clk_fcu);
	$info("Test Case 1, Reset only");
	
	
	TC = 2;
	Input = 8'b10000000;	//SYNC Byte, translation on D_Plus 1(IDLE)->01010100
	WriteFlag = 1;
	@(negedge tb_clk_fcu);
	WriteFlag = 0;
	@(negedge tb_clk_fcu);
	$info("Test Case 2, Sync byte 10000000 was put on FIFO. Expecting 01010100 on D_Plus");

	TC = 3;
	Input = 8'b00101010;		//Data byte 1, translation on D_Plus 0->11001101
	WriteFlag = 1;
	@(negedge tb_clk_fcu);
	WriteFlag = 0;
	@(negedge tb_clk_fcu);
	$info("Test Case 3, byte 00101010 was put on FIFO. Expecting 0->11001101 on D_Plus");

	TC = 4;
	Input = 8'b00110010;		//Data byte 2, translation on D_Plus 1->00100010
	@(negedge tb_clk_fcu);
	WriteFlag = 1;
	@(negedge tb_clk_fcu);
	WriteFlag = 0;
	$info("Test Case 4, byte 00101010 was put on FIFO. Expecting 0->00100010 on D_Plus");

	TC = 5;
	Input = 8'b10101010;		//Data byte 3, translation on D_Plus 0->11001100
	@(negedge tb_clk_fcu);
	WriteFlag = 1;
	@(negedge tb_clk_fcu);
	WriteFlag = 0;
	$info("Test Case 5, byte 10101010 was put on FIFO. Expecting 0->11001100 on D_Plus");

	TC = 6;
	Input = 8'b00101010;		//Data byte 4, translation on D_Plus 0->11001101
	@(negedge tb_clk_fcu);
	WriteFlag = 1;
	@(negedge tb_clk_fcu);
	WriteFlag = 0;
	$info("Test Case 6, byte 00101010 was put on FIFO. Expecting 0->11001101 on D_Plus");

	TC = 7;
	Input = 8'b11111111;		//Data byte 4, translation on D_Plus 0->11001101
	@(negedge tb_clk_fcu);
	WriteFlag = 1;
	@(negedge tb_clk_fcu);
	WriteFlag = 0;
	$info("Test Case 7, byte 11111111 was put on FIFO. Expecting 1->111111000 on D_Plus");

	
	TC = 8;
	if (D_Minus_Out == D_Plus_Out & D_Minus_Out == 0) begin
		$info("Test Case 8. Expecting EOP. Remember to check that after EOP, E_Plus == 1, D_Minus == 0");
		$info("Remember to check timing. From the first tranition edge on D_Plus to the beginning of EOP, there should be 240ns.");
	end
	else begin
		$error("Test Case 5 FAILED! Expecting EOP.");
	end

	end



	/*always begin
	   if(Reset) begin
   	      #0;
   	      if(D_Plus_Out == D_Minus_Out & D_Plus_Out == 1)
      		$error("D_Plus and D_Minus value error here!");
	      else if(D_Plus_Out == 0 & D_Minus_Out == 0)
		$info("Check D_Plus and D_Minus manually. If not EOP, there's an error.");
	   end
	end*/
	

endmodule

