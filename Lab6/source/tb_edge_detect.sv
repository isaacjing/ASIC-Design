// $Id: $
// File name:   tb_edge_detect.sv
// Created:     9/2/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: edge_detect test bench

`timescale 10ns / 10ps

module tb_edge_detect();

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
	
	edge_detect DUT(.clk(tb_clk), .n_rst(Reset), .d_plus(Input), .d_edge(Output));
	initial
	begin
		//TEST CASE 1
		//@(negedge tb_clk);
		TC = 1;
		Reset = 0;
		#4
		Reset = 1;
		@(negedge tb_clk);
		Input = 0;
		#3
		@(negedge tb_clk);
		Input = 1;
		#3
		if (Output == 1) begin
			$info("TC 1 Passed");
		end
		else begin
			$error ("TC 1 Failed. 0-0-1, Expected 1, actual: %d", Output);
		end
	
	//TEST CASE 2
	TC = 2;
	
	@(negedge tb_clk);
	Input = 1;
	@(negedge tb_clk);
	Input = 1;
	@(negedge tb_clk);
	Input = 1;
	#2

	@(negedge tb_clk);

	if (Output == 0) begin
		$info("TC 2 Passed");
	end
	else begin
		$error ("TC 2 Failed. Input 1->1->1, Expected 0, actual: %d", Output);
	end
	
	//TEST CASE 3
	TC = 3;
	Reset = 0;
	#2
	Reset = 1;
	@(negedge tb_clk);
	Input = 1;
	#2
	Input = 0;
	@(negedge tb_clk);
	if (Output == 1) begin
		$info("TC 3 Passed");
	end
	else begin
		$error ("TC 3 Failed. Input 1-0, Expected 1, actual: %d", Output);
	end
	
	
	
	end

endmodule // tb_flex_pts_sr_DUT

