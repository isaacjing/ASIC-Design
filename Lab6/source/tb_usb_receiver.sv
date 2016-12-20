// $Id: $
// File name:   tb_usb_receiver.sv
// Created:     9/2/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: USB 1.0 receiver test bench

`timescale 10ns / 100ps

module tb_usb_receiver();

	// Define parameters
	// basic test bench parameters
	localparam	CLK_PERIOD	= 2;
	
	// Shared Test Variables
	reg tb_clk;
	
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	
	reg Plus;
	reg Minus;
	reg [7:0] ExpectedOutput;
	reg [7:0] Output;
	reg Reset;
	reg ReadEnable;
	reg Empty;
	reg Full;
	reg rcving;
	reg Error;
	integer TC;
	reg [7:0] ByteData;
	
	reg [7:0] Sync = 8'b01010100;
	integer lcv1;
	integer lcv2;
	reg [2:0] TempData = 3'b010;
	
	usb_receiver DUT(.clk(tb_clk), .n_rst(Reset), .d_plus(Plus), .d_minus(Minus), .r_data(Output), .empty(Empty), .full(Full), .rcving(rcving), .r_error(Error), .r_enable(ReadEnable));
	initial
	begin
		//TEST CASE 1
		//@(posedge tb_clk);
		TC = 1;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOut(Sync);
		ShiftDataOut(8'b01101001);
		OutputEOP();
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		ExpectedOutput = 8'b01000101;
		
		if (ExpectedOutput != Output) begin
			$error("Test case 1 failed. Input data is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 1 passed!");
		end

		//TEST CASE 2
		//@(posedge tb_clk);
		TC = 2;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOut(Sync);
		ShiftDataOut(8'b01101001);
		ShiftDataOut(8'b11010011);
		OutputEOP();
		ExpectedOutput = 8'b01000101;
		if (ExpectedOutput != Output) begin
			$error("Test case 2.1 failed. Input data is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 2.1 passed!");
		end
		#2
		ReadOutput();
		ExpectedOutput = 8'b10100011;
		if (ExpectedOutput != Output) begin
			$error("Test case 2.2 failed. Input data is 1->11010011. Thus, and decoded data should be 11000101LSB First, and 10100011 MSB First.");
		end
		else begin
			$info("Test case 2.2 passed!");
		end

		//TEST CASE 3
		//@(posedge tb_clk);
		TC = 3;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOut(8'b01010101);
		#30
		if (Error) begin
			$info("Error flag raised as expected.");
		end
		else begin
			$error("Error flag does not raise, which is unexpected.");
		end
		OutputEOP();
		#10;
		$info("Check state here, expecting EIDLE, state 13");

		//TEST CASE 4
		//@(posedge tb_clk);
		TC = 4;
		#5;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b01101001);
		
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		ExpectedOutput = 8'b01000101;
		
		if (ExpectedOutput != Output) begin
			$error("Test case 4.1 failed. Input data is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 4.1 passed!");
		end
		OutputEOP();

		ShiftDataOut(Sync);
		ShiftDataOut(8'b01101001);
		OutputEOP();
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		ExpectedOutput = 8'b01000101;
		
		if (ExpectedOutput != Output) begin
			$error("Test case 4.3 failed. Input data is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 4.3 passed!");
		end

		//TEST CASE 5
		TC = 5;
		Start();
		ShiftDataOut(Sync);
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			@(posedge tb_clk);
			Plus = TempData[2];
			Minus = ~Plus;
			for (lcv2 = 0; lcv2 < 3; lcv2 ++)
			begin
				@(posedge tb_clk);
			end
			TempData = TempData << 1;
		end
		OutputEOP();
		if (Error) begin
			$info("Test case 5 passed. ");
		end
		else begin
			$error("Test case 5 failed. Error flag does not raise, which is unexpected.");
		end

		//TEST CASE 6
		TC = 6;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b01101001);
		OutputEOP();
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		ExpectedOutput = 8'b01000101;
		if (ExpectedOutput != Output) begin
			$error("Test case 6 failed. Input data is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 6 passed!");
		end

/*		//TEST CASE 7
		TC = 7;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOutFast(Sync);
		ShiftDataOutFast(8'b01101001);
		OutputEOP();
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		ExpectedOutput = 8'b01000101;
		
		if (ExpectedOutput != Output) begin
			$error("Test case 7 failed. Input data (fast rate) is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 7 passed!");
		end

		//TEST CASE 8
		//@(posedge tb_clk);
		TC = 8;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOutFast(Sync);
		ShiftDataOutFast(8'b01101001);
		ShiftDataOutFast(8'b11010011);
		OutputEOP();
		ExpectedOutput = 8'b01000101;
		if (ExpectedOutput != Output) begin
			$error("Test case 8.1 failed. Input data (fast) is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 8.1 passed!");
		end
		#2
		ReadOutput();
		ExpectedOutput = 8'b10100011;
		if (ExpectedOutput != Output) begin
			$error("Test case 8.2 failed. Input data (fast) is 1->11010011. Thus, and decoded data should be 11000101LSB First, and 10100011 MSB First.");
		end
		else begin
			$info("Test case 8.2 passed!");
		end
*/
		//TEST CASE 9
		TC = 9;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOutSlow(Sync);
		ShiftDataOutSlow(8'b01101001);
		OutputEOP();
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		ExpectedOutput = 8'b01000101;
		
		if (ExpectedOutput != Output) begin
			$error("Test case 9 failed. Input data (slow) is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 9 passed!");
		end

		//TEST CASE 10
		//@(posedge tb_clk);
		TC = 10;
		Start();
		#3
		@(posedge tb_clk);
		ShiftDataOutSlow(Sync);
		ShiftDataOutSlow(8'b01101001);
		ShiftDataOutSlow(8'b11010011);
		OutputEOP();
		ExpectedOutput = 8'b01000101;
		if (ExpectedOutput != Output) begin
			$error("Test case 10.1 failed. Input data (slow) is 0->01101001. Thus, and decoded data should be 10100010LSB First, and 01000101 MSB First.");
		end
		else begin
			$info("Test case 10.1 passed!");
		end
		#2
		ReadOutput();
		ExpectedOutput = 8'b10100011;
		if (ExpectedOutput != Output) begin
			$error("Test case 10.2 failed. Input data (slow) is 1->11010011. Thus, and decoded data should be 11000101LSB First, and 10100011 MSB First.");
		end
		else begin
			$info("Test case 10.2 passed!");
		end
	end

	task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			@(posedge tb_clk);
			Plus = TempData[7];
			Minus = ~Plus;
			for (lcv2 = 0; lcv2 < 7; lcv2 ++)
			begin
				@(posedge tb_clk);
			end
			TempData = TempData << 1;
		end
	end
	endtask

	task ShiftDataOutFast;
		input [7:0] InputData;
		reg [7:0] TempData;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			@(posedge tb_clk);
			Plus = TempData[7];
			Minus = ~Plus;
			for (lcv2 = 0; lcv2 < 6; lcv2 ++)
			begin
				@(posedge tb_clk);
			end
			#1
			TempData = TempData << 1;
		end
	end
	endtask

	task ShiftDataOutSlow;
		input [7:0] InputData;
		reg [7:0] TempData;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			@(posedge tb_clk);
			Plus = TempData[7];
			Minus = ~Plus;
			for (lcv2 = 0; lcv2 < 8; lcv2 ++)
			begin
				@(posedge tb_clk);
			end
			TempData = TempData << 1;
		end
	end
	endtask
	
	task Start;
	begin
		Reset = 0;
		#2
		Reset = 1;
		@(posedge tb_clk);
		Plus = 1;
		Minus = 0;
		ReadEnable = 0;
	end
	endtask
	
	task OutputEOP;
		integer lcv2;
	begin
		@(posedge tb_clk);
		Plus = 0;
		Minus = 0;
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk);
		end
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk);
		end
		Plus = 1;
		Minus = 0;
	end
	endtask

	task ReadOutput;
	begin
		ReadEnable = 1;
		#2
		ReadEnable = 0;
		#1;
	end
	endtask
endmodule // tb_flex_pts_sr_DUT

