// $Id: $
// File name:   tb_eop_detect.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: My own test bench for eop_detect.sv

`timescale 1ns / 100ps

module tb_eop_detect();
	localparam NUM_TEST_CASES 		= 6;	
	
	// Declare Design Under Test (DUT) portmap signals
	reg	DPlus = 0;
	reg	DMinus = 0;
	reg	tb_eop;

	
	// Declare test bench signals
	integer tb_test_case;
	
	
	// DUT port map
	eop_detect DUT(.d_plus(DPlus), .d_minus(DMinus), .eop(tb_eop));
	
	// Connect individual test input bits to a vector for easier testing
	//reg DPlus = 0;
	//reg DMinus = 0;
	//assign tb_d_plus = DMinus;
	//assign tb_d_minus = DPlus;
	reg tb_expected_outputs = 0;
	
	// Test bench process
	initial
	begin		
		// Interative Exhaustive Testing Loop
		for(tb_test_case = 0; tb_test_case < NUM_TEST_CASES; tb_test_case = tb_test_case + 1)
		begin
			//$info("Starting Test Case %d", tb_test_case);
			// Wait for a bit to allow this process to catch up with assign statements triggered
			// by test input assignment above
			#2;
			
			// Calculate the expected outputs
			//tb_expected_outputs = ~DPlus & ~DMinus;
			
			// Wait for DUT to process the inputs
			
			

			if (tb_test_case == 0)
			  begin
			    DPlus = 0;
			    DMinus = 0;
				tb_expected_outputs = 1;
			  end
			if (tb_test_case == 1)
			  begin
			    DPlus = 1;
			    DMinus = 0;
				tb_expected_outputs = 0;
			  end
			 if (tb_test_case == 2)
			   begin
			    DPlus = 0;
			    DMinus = 1;
				tb_expected_outputs = 0;
			  end
			 if (tb_test_case == 3)
			  begin
			    DPlus = 1;
			    DMinus = 1;
				tb_expected_outputs = 0;
			  end
			if (tb_test_case == 4)
			   begin
			    DPlus = 0;
			    DMinus = 0;
				tb_expected_outputs = 1;
			  end
			 if (tb_test_case == 5)
			  begin
			    DPlus = 1;
			    DMinus = 1;
				tb_expected_outputs = 0;
			  end
			#5;
			// Check the DUT's Sum and carry out output value
			assert(tb_expected_outputs == tb_eop)
			begin
				$info("Test Case %d passed: plus = %d, minus = %d", tb_test_case, DPlus, DMinus);
			end
			else
			begin
				$error("Test Case %d passed: plus = %d, minus = %d, expected: %d, actual: %d", tb_test_case, DPlus, DMinus, tb_expected_outputs, tb_eop);
			end
		end
	end
endmodule
