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
	
	reg Reset;
	reg Receiving;
	reg Edge;
	reg ShiftEnable;
	reg ByteReceived;
	int TC;
	integer lcv;
	
	timer DUT(.clk(tb_clk), .n_rst(Reset), .d_edge(Edge), .rcving(Receiving), .shift_enable(ShiftEnable), .byte_received(ByteReceived));
	initial
	begin
		Reset = 1;
		//TEST CASE 1
		//@(negedge tb_clk);
		TC = 1;
		#2;
		lcv = 0;
		while(lcv < 2) begin
			Receiving = 1;
			@(negedge tb_clk);
			#1;
			lcv += 1;
		end
		if ( ShiftEnable == 1) begin
			$info("TC 1 Passed");
		end
		else begin
			$error ("TC 1 Failed. Timer Output should be 2, and ShiftEnable should be high actual: %d", ShiftEnable);
		end
		
		//TEST CASE 1
		@(negedge tb_clk);
		TC = 2;
		#2;
		Receiving = 0;
		d_edge = 1;
		if ( ShiftEnable == 0) begin
			$info("TC 2 Passed");
		end
		else begin
			$error ("TC 2 Failed. Timer Output should be 0, and ShiftEnable should be low actual: %d", ShiftEnable);
		end

		//TEST CASE 3
		@(negedge tb_clk);
		TC = 3;
		#2;
		lcv = 0;
		while(lcv < 64) begin
			Receiving = 1;
			@(negedge tb_clk);
			#1;
			lcv += 1;
		end
		if ( ShiftEnable == 0) begin
			$info("TC 3.1 Passed");
		end
		else begin
			$error ("TC 3.1 Failed. Timer Output should be 0, and ShiftEnable should be low actual: %d", ShiftEnable);
		if (byte_received == 1) begin:
			$info("TC 3.2 Passed");
		end
		else begin
			$error ("TC 3.2 Failed. Timer Output should be 0, and ByteReceived should be 1 actual: %d", ShiftEnable);
		end

		//TEST CASE 4
		@(negedge tb_clk);
		Reset = 0;
		#2;
		Reset = 1;
		TC = 4;
		#2;
		lcv = 0;
		while(lcv < 65) begin
			Receiving = 1;
			@(negedge tb_clk);
			#1;
			lcv += 1;
		end
		if ( ShiftEnable == 0) begin
			$info("TC 4.1 Passed");
		end
		else begin
			$error ("TC 4.1 Failed. Timer Output should be 0, and ShiftEnable should be low actual: %d", ShiftEnable);
		if (byte_received == 0) begin:
			$info("TC 4.2 Passed");
		end
		else begin
			$error ("TC 4.2 Failed. Timer Output should be 0, and ByteReceived should be 0 actual: %d", ShiftEnable);
		end
	
	
		//TEST CASE 5
		@(negedge tb_clk);
		Reset = 0;
		#2;
		Reset = 1;
		TC = 5;
		#2;
		lcv = 0;
		while(lcv < 128) begin
			Receiving = 1;
			@(negedge tb_clk);
			#1;
			lcv += 1;
		end
		if ( ShiftEnable == 0) begin
			$info("TC 5.1 Passed");
		end
		else begin
			$error ("TC 5.1 Failed. Timer Output should be 0, and ShiftEnable should be low actual: %d", ShiftEnable);
		if (byte_received == 0) begin:
			$info("TC 5.2 Passed");
		end
		else begin
			$error ("TC 5.2 Failed. Timer Output should be 1, and ByteReceived should be 1 actual: %d", ShiftEnable);
		end
	
	end

endmodule // tb_flex_pts_sr_DUT

