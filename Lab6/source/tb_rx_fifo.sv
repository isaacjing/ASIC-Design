// $Id: $
// File name:   tb_rx_fifo.sv
// Created:     9/2/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: tb_rx_fifo test bench

`timescale 1ns / 10ps

module tb_rx_fifo();

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
	
	reg [7:0] Input;
	reg [7:0] Output;
	reg Reset;
	reg ReadFlag;
	reg WriteFlag;
	reg EmptyFlag;
	int TC;
	
	rx_fifo DUT(.clk(tb_clk), .n_rst(Reset), .r_enable(ReadFlag), .w_enable(WriteFlag), .r_data(Output), .w_data(Input), .empty(EmptyFlag));
	initial
	begin
		//TEST CASE 1
		//@(negedge tb_clk);
		TC = 1;
		Reset = 0;
		#2
		Reset = 1;
		@(negedge tb_clk);
		
		if (EmptyFlag == 1) begin
			$info("TC 1 Passed");
		end
		else begin
			$error ("TC 1 Failed. After reset, Empty Flag is: %d", EmptyFlag);
		end
	
		Input = 8'd10;
		WriteFlag = 1;
		#2;
		WriteFlag = 0;
		#2;
		Input = 8'd15;
		WriteFlag = 1;
		#2;
		WriteFlag = 0;
		#2;
		Input = 8'd88;
		WriteFlag = 1;
		#2;
		WriteFlag = 0;
	//TEST CASE 2
	TC = 2;
	#2	
	@(negedge tb_clk);
	if (Output == 8'd10) begin
		$info("TC 2 Passed");
	end
	else begin
		$error ("TC 2 Failed. Input 10->15->88, Expected 10, actual: %d", Output);
	end
	ReadFlag = 1;
	#2;
	ReadFlag = 0;

	//TEST CASE 3
	TC = 3;
	#2	
	@(negedge tb_clk);
	if (Output == 8'd15) begin
		$info("TC 3 Passed");
	end
	else begin
		$error ("TC 3 Failed. Input 15->88, Expected 15, actual: %d", Output);
	end
	ReadFlag = 1;
	#2;
	ReadFlag = 0;
	
	//TEST CASE 3.1
	Input = 8'd66;
	WriteFlag = 1;
	#2;
	WriteFlag = 0;
	#2;
	
	//TEST CASE 4
	TC = 4;
	#2	
	@(negedge tb_clk);
	if (Output == 8'd88) begin
		$info("TC 4 Passed");
	end
	else begin
		$error ("TC 4 Failed. Input 88->66, Expected 88, actual: %d", Output);
	end
	ReadFlag = 1;
	#2;
	ReadFlag = 0;
	
	
	//TEST CASE 5
	TC = 5;
	Reset = 0;
	#2
	Reset = 1;	
	#4
	if (Output == '0 && EmptyFlag == 1) begin
		$info("TC 5 Passed");
	end
	else begin
		$error ("TC 5 Failed. Reset again, Expected 0 Output, 1 Empty, actual: %d, %d", Output, EmptyFlag);
	end

	//TEST CASE 1
		//@(negedge tb_clk);
		TC = 5;
		Reset = 0;
		#2
		Reset = 1;
		@(negedge tb_clk);
		
		Input = 8'd588;
		WriteFlag = 1;
		#150;
		WriteFlag = 0;
		ReadFlag = 1;
		#150;
		//TEST CASE 1
		//@(negedge tb_clk);
		TC = 6;
		Reset = 0;
		#2
		Reset = 1;
		@(negedge tb_clk);
		
		Input = 8'd365;
		WriteFlag = 1;
		#150;
		WriteFlag = 0;
		ReadFlag = 1;
		#150;
		//TEST CASE 1
		//@(negedge tb_clk);
		TC = 7;
		Reset = 0;
		#2
		Reset = 1;
		@(negedge tb_clk);
		
		Input = 8'd674;
		WriteFlag = 1;
		#150;
		WriteFlag = 0;
		ReadFlag = 1;
		#150;
		
		
	
	end

endmodule // tb_flex_pts_sr_DUT

