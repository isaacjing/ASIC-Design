// $Id: $
// File name:   tb_USB_Transceiver.sv
// Created:     9/2/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: USB 1.0 Transceiver test bench, obsolete now.

`timescale 1ns / 100ps

module tb_USBTransceiver();

	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIODUSB	= 10;
   	localparam  CLK_PERIODFCU = 20;
	
	// Shared Test Variables
	reg tb_clk_usb = 1'b0;
	reg tb_clk_fcu = 1'b0;
	
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
	
	wire Plus;
	wire Minus;
	reg Plus_in;
	reg Minus_in;

	reg Plus_in_temp;
	reg Minus_in_temp;

	wire Plus_out;
	wire Minus_out;
	reg USBOE;
	reg [7:0] ExpectedOutput;
	reg [7:0] Output_Value;
	reg [7:0] Address;
	reg Reset;
	reg Reset2;
	reg ReadEnable;
	reg ReadFlag;
	reg Empty;
	reg Full;
	reg [7:0] FifoOut;
	reg [7:0] Snt_data;
	reg rcving;
	reg W_enable_e;
	reg Input_Enable;
	reg Error;
	reg [3:0] Request;
	reg [2:0] Status;
	integer TC;
	reg [7:0] ByteData;
	reg Output_Enable;
	reg [7:0] Out_Data;
	reg [7:0] Rcv_data;
	reg FUll_in;
	reg R_enable_e;
	integer lcv1;
	integer lcv2;
	reg [2:0] TempData = 3'b010;

	reg LoadData;
	wire LoadEnable;
	reg [7:0] LoadDataTest;
	reg EmptyTest;
	wire ReadEnableTest;
	reg Loading;
	reg [7:0] fifo_input_test;
	reg [7:0] Out_Data_test;

	reg Last = 1;
	reg [3:0] Count = 0;

	localparam [7:0] Sync = 8'b10000000;
	localparam [7:0] PIDSetup = 8'b11010010;
	localparam [7:0] Data0 = 8'b00111100;
	localparam [7:0] Data1 = 8'b10110100;
	localparam [7:0] PIDOut = 8'b00011110;
	
	USBTransceiver DUT(.clk(tb_clk_usb), .n_rst(Reset), .D_Plus_in(Plus_in), .D_Minus_in(Minus_in), .D_Plus_out(Plus_out), .D_Minus_out(Minus_out), .Snt_data(Snt_data), .Address(Address), .Request(Request), .Status(Status), .W_enable_e(W_enable_e), .Out_Data(Out_Data), .R_enable_e(R_enable_e), .empty(empty), .W_enable_d(W_enable_d), .Rcv_data(Rcv_data), .Input_Enable(Input_Enable), .Output_Enable(Output_Enable), .Output_Value(Output_Value), .USBOE(USBOE));

	usb_receiver_lab6 LAB6RECEIVE(.clk(tb_clk_usb), .n_rst(Reset & Reset2), .d_plus(Plus_out), .d_minus(Minus_out), .r_enable(ReadFlag), .r_data(FifoOut), .full(), .empty(), .rcving(), .r_error());

	RX_FIFO #(.NUM_BYTES(8)) RX_FIFO_OUT (.readClock(tb_clk_usb), .writeClock(tb_clk_fcu), .n_rst(Reset), .r_enable(R_enable_e), .w_enable(W_enable_e), .r_data(Snt_data), .w_data(Out_Data), .empty(empty), .full(Full));

	RX_FIFO #(.NUM_BYTES(8)) RX_FIFO_IN (.readClock(tb_clk_fcu), .writeClock(tb_clk_usb), .n_rst(Reset), .r_enable(Input_Enable), .w_enable(W_enable_d), .r_data(fifo_input), .w_data(Rcv_data), .empty(), .full(Full_in));

	/*SimpleUSBTransmitter SimpleTransmitter (.clk(clk), .empty(EmptyTest), .D_Plus_Out(Plus_in_temp), .D_Minus_Out(Minus_in_temp), .N_reset(Reset), .Encode_Instruction(), .Snt_data(fifo_input_test), .W_enable_e(LoadEnable), .out_data(Out_Data_test), .Output_Enable(Loading), .Output_Value(LoadDataTest), .r_enable_e(ReadEnableTest), .Encode_Status());

	RX_FIFO #(.NUM_BYTES(8)) RX_FIFO_TEST (.readClock(tb_clk_fcu), .writeClock(tb_clk_usb), .n_rst(Reset), .r_enable(ReadEnableTest), .w_enable(LoadEnable), .r_data(fifo_input_test), .w_data(Out_Data_test), .empty(EmptyTest));*/

	
	assign Plus = ~USBOE ? Plus_in : Plus_out;
	assign Minus = ~USBOE ? Minus_in : Minus_out;
	//assign Plus_out = USBOE ? Plus : 'z;
	//assign Minus_out = USBOE ? Minus : 'z;


	initial
	begin
		Plus_in <= 1;
		Minus_in <= 0;
		ReadFlag = 0;
		Start();
	        /*//TEST CASE 1
		TC = 1;
		$info("Start sending TOKEN for SETUP");
		Plus_in <= 0;
		Minus_in <= 1;
		Plus_in_temp = 1;
		Minus_in_temp = 0;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b00011110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000001);	//Host Requesting Read
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);
		ShiftDataOut(8'b01000111);
		ShiftDataOut(8'b01011010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");

		#830;
		#640;
		
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 1 passed. ACK success received as expected");

		end
		else
			$error("Test Case 1 failed. ACK does not receive as expected");

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b00011110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000001);	//Host Requesting Read
		ShiftDataOut(8'b01010101);	//Address byte 1 //Page address (Start): 010101 (21), block address: 0011010100 (212), page address (end): 010111 (23)
		ShiftDataOut(8'b11010100);	//Address byte 2
		ShiftDataOut(8'b01010111);	//Address byte 3
		ShiftDataOut(8'b01101001);
		ShiftDataOut(8'b11111001);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#850;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 1.1 passed. ACK success received as expected");

		end
		else
			$error("Test Case 1.2 failed. ACK does not receive as expected");

		ReadInput();


		//Test Case 2
		TC = 2;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b00011110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000010);	//Host Requesting Write
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);
		ShiftDataOut(8'b01000100);
		ShiftDataOut(8'b01101010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");
		
		#830;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 2.1 passed. ACK success received as expected");

		end
		else
			$error("Test Case 2.1 failed. ACK does not receive as expected");

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b00011110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000010);	//Host Requesting Read
		ShiftDataOut(8'b01110101);	//Address byte 1 //Page address (Start): 011101 (19), block address: 0111010100 (468), page address (end): 010111 (23)
		ShiftDataOut(8'b11010100);	//Address byte 2
		ShiftDataOut(8'b01001101);	//Address byte 3
		ShiftDataOut(8'b10101110);
		ShiftDataOut(8'b0100101);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#850;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 2.2 passed. ACK success received as expected");

		end
		else
			$error("Test Case 2.2 failed. ACK does not receive as expected");

		ReadInput();*/

		//Test Case 3
		TC = 3;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b00011110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000011);	//Host Requesting Erase
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);
		ShiftDataOut(8'b01100110);
		ShiftDataOut(8'b10111001);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");
		
		#830;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 3.1 passed. ACK success received as expected");

		end
		else
			$error("Test Case 3.1 failed. ACK does not receive as expected");

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b00011110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000011);	//Host Requesting Read
		ShiftDataOut(8'b01110101);	//Address byte 1 //Page address (Start): 011101 (19), block address: 0111010100 (468), page address (end): 10010 (18)
		ShiftDataOut(8'b11010100);	//Address byte 2
		ShiftDataOut(8'b01001001);	//Address byte 3
		ShiftDataOut(8'b01000011);
		ShiftDataOut(8'b00111101);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#850;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 3.2 passed. ACK success received as expected");

		end
		else
			$error("Test Case 3.2 failed. ACK does not receive as expected");

		ReadInput();
	end
	
	task Start;
	begin
		Plus_in_temp = 1;
		Minus_in_temp = 0;
		Reset <= 0;
		ReadEnable <= 0;
		@(posedge tb_clk_usb);
		#2ns;
		Reset <= 1;
	end
	endtask
	
	task OutputEOP;
		integer lcv2;
	begin
		@(posedge tb_clk_usb);
		Plus_in = '0;
		Minus_in = '0;
		Plus_in_temp = '0;
		Minus_in_temp = '0;
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk_usb);
		end
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk_usb);
		end
		Plus_in = 1;
		Minus_in = 0;
		Plus_in_temp = 1;
		Minus_in_temp = 0;
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk_usb);
		end
	end
	endtask

	/*task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
		reg [8:0] BitStuffedData;
		reg BitStuffed;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			if (TempData[lcv1] == Last)
				
		end
	end
	endtask*/

	task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
		reg BitStuffed;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			Plus_in = (TempData[lcv1] == 1'b1) ? Plus_in_temp : ~Plus_in_temp;
			Minus_in = (TempData[lcv1] == 1'b1) ? Minus_in_temp : ~Minus_in_temp; 
			Plus_in_temp = Plus_in;
			Minus_in_temp = Minus_in;
			if (TempData[lcv1] == 1'b1) begin
				Count += 1;
			end
			else
				Count = '0;
			
			for (lcv2 = 0; lcv2 < 8; lcv2 ++)
			begin
				@(posedge tb_clk_usb);
			end
			if (Count == 4'd6) begin
				Plus_in = ~Plus_in_temp;
				Minus_in = ~Minus_in_temp;

				Plus_in_temp = Plus_in;
				Minus_in_temp = Minus_in;
				for (lcv2 = 0; lcv2 < 8; lcv2 ++)
				begin
					@(posedge tb_clk_usb);
				end	
				Count = '0;
			end
			//TempData = TempData>>1;		
		end
	end
	endtask

	/*task Translate;
		input [7:0] InputData;
		reg [7:0] TempData;
		reg [8:0] Out;
		integer lcv;
	begin
		TempData = InputData;
		
	end
	endtask*/

	/*task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
	begin
		TempData = InputData;
		LoadDataTest = TempData;
		Loading = 1;
		#10;
		Loading = 0;
		#70;
		#559;
	end
	endtask*/

	task ReadInput;
	begin
		ReadFlag = 1;
		#10;
		ReadFlag = 0;
		#1;
	end
	endtask //

endmodule // tb_flex_pts_sr_DUT

