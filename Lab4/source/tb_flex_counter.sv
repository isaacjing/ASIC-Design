// $Id: $
// File name:   tb_flex_counter.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: tb_flex_counter.sv

`timescale 1ns / 100ps

module tb_flex_counter
#(
	parameter NUM_BITS = 4
);
	localparam	CLK_PERIOD	= 2.5;
	localparam	CHECK_DELAY = 1;
	
	// Test Variables
	reg tb_clk;
	reg reset;
	reg clear;
	reg enable;
	wire [NUM_BITS - 1:0] count;
	reg [NUM_BITS - 1:0] rollover_val;
	reg [NUM_BITS - 1:0] temp;
	reg rollover_flag;

	
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
	


	flex_counter DUT(.clk(tb_clk), .n_rst(reset), .clear(clear), .count_enable(enable), .rollover_val(rollover_val), .count_out(count), .rollover_flag(rollover_flag));

	initial
	begin
	//TEST CASE 1: Test Reset
	TestCase = 1;
	enable = 1;
	clear = 0;
	reset = 0;
	rollover_val = 2 ** NUM_BITS - 1;
	
	#CLK_PERIOD;	//delay
	#CLK_PERIOD;

	reset = 1;
	
	@(posedge tb_clk);
	@(negedge tb_clk);
	
	reset = 0;
	@(posedge tb_clk);
	
	if (count == 0)
	begin
		$info("Case 1: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 1 (Reset) Expect: %d, Actual %d", 2**NUM_BITS - 1, count);
	end

	#CLK_PERIOD;
	
	//TEST CASE 2: Test Clear
	TestCase = 2;
	enable = 1;
	clear = 0;
	reset = 1;
	rollover_val = 2 ** NUM_BITS - 1;
	
	#CLK_PERIOD;	//delay
	@(posedge tb_clk);
	@(negedge tb_clk);

	clear = 1;
	//@(posedge tb_clk);
	#CLK_PERIOD;
	if (count == 0)
	begin
		$info("Case 2: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 2 (Clear) Expect: 0, Actual %d", count);
	end


	//TEST CASE 3: Test Count Enable.
	TestCase = 3;
	enable = 1;
	clear = 0;
	reset = 1;
	rollover_val = 2 ** NUM_BITS - 1;
	
	#20;
	temp = count;	
	enable = 0;

	#CLK_PERIOD;	//delay
	#CLK_PERIOD;
	
	if (count == temp)
	begin
		$info("Case 3: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 3 (Count enable) Expect: %d, Actual %d", temp, count);
	end

	//TEST CASE 4: Test Counting 1
	TestCase = 4;
	enable = 0;
	clear = 0;
	reset = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	reset = 1;
	rollover_val = 2 ** NUM_BITS - 1;
	temp = count;	
	enable = 1;

	#CLK_PERIOD;	//delay
	#CLK_PERIOD;
	#CLK_PERIOD;
	#CLK_PERIOD;

	if (count == temp + 4)
	begin
		$info("Case 4: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 4 (Adding) Expect: %d, Actual %d", temp + 4, count);
	end

	//TEST CASE 5: Test Counting 2
	TestCase = 5;
	enable = 0;
	clear = 0;
	reset = 0;
	#CLK_PERIOD;
	#CLK_PERIOD;
	
	reset = 1;
	rollover_val = 2 ** NUM_BITS - 1;
	temp = count;	
	enable = 1;

	#20;	//delay

	if (count == temp + 8)
	begin
		$info("Case 5: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 5 (Adding) Expect: %d, Actual %d", temp + 8, count);
	end

	//TEST CASE 6: Test Roll Over
	TestCase = 6;
	enable = 0;
	clear = 0;
	reset = 0;
	#5
	reset = 1;
	rollover_val = 5;
	temp = count;	
	enable = 1;

	#14;	//delay
	if (rollover_flag == 1)
	begin
		$info("Case 6.1: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 6.1 (Roll over flag) Expect: 1, Actual %d", rollover_flag);
	end
	
	#2.5
	if (count == 1)
	begin
		$info("Case 6.2: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 6.2 (Roll over) Expect: 1, Actual %d", count);
	end
	
	
	
	if (rollover_flag == 0)
	begin
		$info("Case 6.3: PASSED");
	end
	else
	begin
		$error("!FAILED! Case 6.3 (Roll over flag) Expect: 0, Actual %d", rollover_flag);
	end
	
	//TEST CASE 7: For loop checking
	for (lcv = 1; lcv <= 15; lcv++)
	begin
	  @(posedge tb_clk);
	  @(negedge tb_clk);
	  enable = 0;
	  clear = 0;
	  reset = 0;
	  #CLK_PERIOD;
	  #CLK_PERIOD;
	
	  reset = 1;
	  rollover_val = '1;
	  temp = count;	
	  enable = 1;

	  #(lcv * 2.5);	//delay
	  #1.5
	  if (count == temp + lcv)
	  begin
		$info("Case 7.%d: PASSED", lcv);
	  end
	  else
	  begin
		$error("!FAILED! Case 7.%d (Adding) Expect: %d, Actual %d", lcv, temp + lcv, count);
	  end
	end
	
      end

endmodule
