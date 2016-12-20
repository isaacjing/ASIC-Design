// $Id: $
// File name:   tb_edge_detect.sv
// Created:     9/2/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: edge_detect test bench

`timescale 10ns / 100ps

module tb_decode();

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
	
	reg Input;
	reg ShiftEnable;
	reg ExpectedOutput;
	reg Output;
	reg Reset;
	reg EOP;
	int TC;
	
	decode DUT(.clk(tb_clk), .n_rst(Reset), .d_plus(Input), .d_orig(Output), .shift_enable(ShiftEnable), .eop(EOP));
	initial
	begin
		Input = 0;
		//TEST CASE 1
		//@(posedge tb_clk);
		TC = 1;
		Reset = 0;
		#2
		Reset = 1;
		@(posedge tb_clk);
		ShiftEnable = 1;
		EOP = 1;
		@(posedge tb_clk);
		
		#2
		if (Output == 1) begin
			$info("TC 1 Passed");
		end
		else begin
			$error ("TC 1 Failed. EOP = 1, ShiftEnable = 1, Expected 1, actual: %d", Output);
		end
		ShiftEnable = 0;
	EOP = 0;
	//TEST CASE 2
	TC = 2;
	Reset = 0;
	#3
	Reset = 1;
	@(posedge tb_clk);
	Input = 0;
	@(posedge tb_clk);
	Input = 0;
	@(posedge tb_clk);
	Input = 1;
	#4
	@(posedge tb_clk);
	ShiftEnable = 1;
	#2
	@(posedge tb_clk);
	ShiftEnable = 0;
	if (Output == 0) begin
		$info("TC 2 Passed");
	end
	else begin
		$error ("TC 2 Failed. Input 1->1->0, Expected 0, actual: %d", Output);
	end
	
	//TEST CASE 3
	TC = 3;
	#6
	@(posedge tb_clk);
	ShiftEnable = 1;
	#2
	@(posedge tb_clk);
	ShiftEnable = 0;
	if (Output == 1) begin
		$info("TC 3 Passed");
	end
	else begin
		$error ("TC 3 Failed. Input 1->1->0, Expected 1, actual: %d", Output);
	end
	
	//TEST CASE 4
	TC = 4;
	#6
	@(posedge tb_clk);
	Input = 1;
	@(posedge tb_clk);
	Input = 0;
	#2
	@(posedge tb_clk);
	Input = 0;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#2
	@(posedge tb_clk);
	ShiftEnable = 0;
	
	if (Output == 0) begin
		$info("TC 4 Passed");
	end
	else begin
		$error ("TC 4 Failed. Input 1->1->0, Expected 0, actual: %d", Output);
	end
	#2;
        //TEST CASE 5
	TC = 5;
	Reset = 0;
	#3
	Reset = 1;
	@(posedge tb_clk);
	Input = 0;
	@(posedge tb_clk);
	Input = 0;
	@(posedge tb_clk);
	Input = 1;
	#4
	@(posedge tb_clk);
	//ShiftEnable = 1;
	//EOP = 1;
	@(posedge tb_clk);
		
	#2
	if (Output == 1) begin
		$info("TC 5 Passed");
	end
	else begin
		$error ("TC 5 Failed. EOP = 1, ShiftEnable = 1, Expected 1, actual: %d", Output);
	end

	if (Output == 0) begin
		$info("TC 2 Passed");
	end
	else begin
		$error ("TC 2 Failed. Input 1->1->0, Expected 0, actual: %d", Output);
	end
	
	//TEST CASE 6
	TC = 6;
	EOP = 0;
	Reset = 0;
	#3
	Reset = 1;
	@(posedge tb_clk);
	Input = 1;
	#2;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#1;
	@(posedge tb_clk);
	ShiftEnable = 0;
	#1
	@(posedge tb_clk);
	Input = 0;
	EOP = 1;
	#1;
	@(posedge tb_clk);
	#5;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#1;
	@(posedge tb_clk);
	ShiftEnable = 0;
	#8;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#1;
	@(posedge tb_clk);
	ShiftEnable = 0;
	#4;
	@(posedge tb_clk);
	Input = 1;
	EOP = 0;
	#3;

	//TEST CASE 7
	TC = 7;
	EOP = 0;
	Reset = 0;
	#3
	Reset = 1;
	@(posedge tb_clk);
	Input = 0;
	#2;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#1;
	@(posedge tb_clk);
	ShiftEnable = 0;
	#1
	@(posedge tb_clk);
	Input = 0;
	EOP = 1;
	#1;
	@(posedge tb_clk);
	#5;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#1;
	@(posedge tb_clk);
	ShiftEnable = 0;
	#8;
	@(posedge tb_clk);
	ShiftEnable = 1;
	#1;
	@(posedge tb_clk);
	ShiftEnable = 0;
	#4;
	@(posedge tb_clk);
	Input = 1;
	EOP = 0;
	end

endmodule // tb_flex_pts_sr_DUT

