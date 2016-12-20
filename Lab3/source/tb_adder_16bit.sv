// $Id: $
// File name:   tb_adder_16bit.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: My own test bench for adder_16bit

`timescale 1ns / 100ps

module tb_adder_16bit
();
	localparam NUM_TEST_CASES 		= 6;	
	
	// Declare Design Under Test (DUT) portmap signals
	wire	[15:0] tb_a;
	wire	[15:0] tb_b;
	wire	tb_carry_in;
	wire	[15:0] tb_sum;
	wire	tb_carry_out;
	
	// Declare test bench signals
	integer tb_test_case;
	//reg [15:0] tb_test_inputs;
	reg [16:0] tb_expected_outputs;
	reg no_match;
	
	// DUT port map
	adder_16bit DUT(.a(tb_a), .b(tb_b), .carry_in(tb_carry_in), .sum(tb_sum), .overflow(tb_carry_out));
	
	// Connect individual test input bits to a vector for easier testing
	reg [15:0] a = 0;
	reg [15:0] b = 0;
	reg carry_in = 0;
	assign tb_a[15:0] = a[15:0];
	assign tb_b[15:0] = b[15:0];
	assign tb_carry_in = carry_in;
	
	// Test bench process
	initial
	begin
		no_match = 0;
		
		// Interative Exhaustive Testing Loop
		for(tb_test_case = 0; tb_test_case < NUM_TEST_CASES; tb_test_case = tb_test_case + 1)
		begin
			// Wait for a bit to allow this process to catch up with assign statements triggered
			// by test input assignment above
			#1;
			
			// Calculate the expected outputs
			tb_expected_outputs = tb_a + tb_b + tb_carry_in;
			
			// Wait for DUT to process the inputs
			#(9);
			
			// Check the DUT's Sum and carry out output value
			assert(tb_expected_outputs[15 : 0] == tb_sum && tb_expected_outputs[16] == tb_carry_out)
			begin
				$info("Test Case %d passed: a = %d, b = %d, carry_in = %d, sum = %d, carry_out = %d", tb_test_case, tb_a, tb_b, tb_carry_in, tb_sum, tb_carry_out);
			end
			else
			begin
				$error("ERROR!!!!! Test Case %d FAILED: a = %d, b = %d, carry_in = %d, sum = %d, carry_out = %d", tb_test_case, tb_a, tb_b, tb_carry_in, tb_sum, tb_carry_out);
				no_match = 1;
			end

			if (tb_test_case == 0)
			  begin
			    a = 16'b1111111111111111;
			    b = 0;
			  end
			if (tb_test_case == 1)
			  begin
			    a = 0;
			    b = 16'b1111111111111111;
			  end
			 if (tb_test_case == 2)
			   begin
			    a = 16'b1111111111111111;
			    b = 16'b1111111111111111;
			   end
			 if (tb_test_case == 3)
			  begin
			    a = 16'b0000000000001101;
			    b = 16'b0000000000001000;
			    //carry_in = 1;
			  end
			 if (tb_test_case == 4)
			  begin
			    a = 16'b0000001000001101;
			    b = 16'b0001001001001000;
			    carry_in = 1;
			  end
		end
	end
endmodule
