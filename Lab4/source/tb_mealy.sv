// $Id: $
// File name:   tb_flex_counter.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: tb_flex_counter.sv

`timescale 1ns / 100ps

module tb_mealy ();

	localparam	CLK_PERIOD	= 2.5;
	localparam	CHECK_DELAY = 1;
	
	// Test Variables
	reg tb_clk;
	reg reset;
	reg Out;
	reg [15:0] Values;
	reg [14:0] Trash;
	reg i;
	
	integer TestCase;
	integer lcv;
	// Clock generation block
	always
	begin
		tb_clk = 1'b0;
		#(CLK_PERIOD/2.0);
		tb_clk = 1'b1;
		#(CLK_PERIOD/2.0);
	end
	


	mealy DUT(.clk(tb_clk), .n_rst(reset), .i(i), .o(Out));

	initial
	begin
	//TEST CASE 1: Test Reset
	TestCase = 1;
	reset = 0;
	
	#CLK_PERIOD;	//delay
	#CLK_PERIOD;

	reset = 1;
	
	@(posedge tb_clk);
	@(negedge tb_clk);
	
	reset = 0;
	@(posedge tb_clk);
	
	if (Out == 0)
	begin
		$info("Case 1: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 1 (Reset) Expect: 0, Actual %d", Out);
	end

	#CLK_PERIOD;
	
	//TEST CASE 2: Input 1101
	reset = 0;
	#CLK_PERIOD;	//delay
	TestCase = 2;
	Values = 16'b0000000000010110;
	reset = 1;
	
	#CLK_PERIOD;	//delay
	@(posedge tb_clk);
	@(negedge tb_clk);

	lcv = 0;
	while (lcv < 4)
	begin
	  Values = Values >> 1;
	  i = Values & 1'b1;
	  lcv++;
	  if (lcv != 4)
	    #CLK_PERIOD;
	end
	#1;
	if (Out == 1)
	begin
		$info("Case 2 (1101): PASSED");
	end
	else
	begin
		$error("!FAILED! Case 2 (1101) Expect: 1, Actual %d", Out);
	end


	//TEST CASE 3: 11010.
	TestCase = 3;
	reset = 0;
	#CLK_PERIOD;	//delay
	
	Values = 16'b0000000000010110;
	reset = 1;
	
	#CLK_PERIOD;	//delay
	@(posedge tb_clk);
	@(negedge tb_clk);

	lcv = 0;
	while (lcv < 5)
	begin
	  Values = Values >> 1;
	  i = Values & 1'b1;
	  lcv++;
	  if (lcv != 5)
	    #CLK_PERIOD;
	end
	#1;
	if (Out == 0)
	begin
		$info("Case 3 (11010): PASSED");
	end
	else
	begin
		$error("!FAILED! Case 3 (11010) Expect: 0, Actual %d", Out);
	end

	//TEST CASE 4: 11011101
	TestCase = 4;
	reset = 0;
	#CLK_PERIOD;	//delay
	
	Values = 16'b0000000101110110;
	reset = 1;
	
	#CLK_PERIOD;	//delay
	@(posedge tb_clk);
	@(negedge tb_clk);

	lcv = 0;
	while (lcv < 8)
	begin
	  Values = Values >> 1;
	  i = Values & 1'b1;
	  lcv++;
	  if (lcv != 8)
	    #CLK_PERIOD;
	end
	#1;
	if (Out == 1)
	begin
		$info("Case 4 (11011101): PASSED");
	end
	else
	begin
		$error("!FAILED! Case 4 (11011101) Expect: 1, Actual %d", Out);
	end

	//TEST CASE 5: 1101101
	TestCase = 5;
	reset = 0;
	#CLK_PERIOD;	//delay
	
	Values = 16'b0000000010110110;
	reset = 1;
	
	#CLK_PERIOD;	//delay
	@(posedge tb_clk);
	@(negedge tb_clk);

	lcv = 0;
	while (lcv < 7)
	begin
	  Values = Values >> 1;
	  i = Values & 1'b1;
	  lcv++;
	  if (lcv != 7)
	    #CLK_PERIOD;
	end
	#1;
	if (Out == 1)
	begin
		$info("Case 5 (1101101): PASSED");
	end
	else
	begin
		$error("!FAILED! Case 5 (1101101) Expect: 1, Actual %d", Out);
	end
	
	//TEST CASE 6: 11010011
	TestCase = 5;
	reset = 0;
	#CLK_PERIOD;	//delay
	
	Values = 16'b0000000011010110;
	reset = 1;
	
	#CLK_PERIOD;	//delay
	@(posedge tb_clk);
	@(negedge tb_clk);

	lcv = 0;
	while (lcv < 7)
	begin
	  Values = Values >> 1;
	  i = Values & 1'b1;
	  lcv++;
	  if (lcv != 7)
	    #CLK_PERIOD;
	end
	#1;
	if (Out == 0)
	begin
		$info("Case 6 (1101011): PASSED");
	end
	else
	begin
		$error("!FAILED! Case 6 (1101011) Expect: 0, Actual %d", Out);
	end
	
      end

endmodule
