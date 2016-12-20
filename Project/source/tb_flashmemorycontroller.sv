// $Id: $
// File name:   tb_flashmemorycontroller.sv
// Created:     11/2/2015
// Author:      Jing, Jiangshan
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: tb_USB_Transmitter test bench, used to be the test bench for flash memory controller

`timescale 1ns / 10ps

module tb_flashmemorycontroller();

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

	reg [3:0] Status;
	reg [3:0] Request = 4'b0000;
	reg [7:0] Output;
	reg Reset;
	reg [7:0] Input;
	reg [7:0] Address;
	reg Error;
	reg EmptyFlag;
	reg Full;
	wire [7:0] FDataIn;
	wire [7:0] FDataOut;
	reg FDataOE2;
	reg FDataOE;
	reg RE_n;
	reg WE_n;
	reg ALE;
	reg [7:0] temp;
	reg CLE;
	reg CE_n;
	reg WP_n;
	reg RB;
	reg [15:0] Byte;
	reg [7:0] b;
	reg OutputShift;
	int TC;
	int lcv;
	wire [7:0] io;
	
	reg Output_Selection;
	reg [15:0] Length;
	

	flashmemorycontroller DIU (
		// Internal		
		.Status, .clk2(tb_clk_fcu), .NReset(Reset), .Address, .Input, .Full, .FDataOut, .Request, .OutputShift, .FDataIn, .FDataOE,
		// Flash
		.RE_n, .WE_n, .CLE, .ALE, .CE_n, .WP_n, .RB, .FDataIn);
        
	flash FLASH(.*);
	assign io = FDataOE ? FDataIn: 'z;
	assign FDataOut = io;

	default clocking fcb @(posedge tb_clk_fcu);
                // 1step means 1 time precision unit, 10ps for this module. We assume the hold time is less than 200ps.
                default input #1step output #100ps; // Setup time (01CLK -> 10D) is 94 ps
                output #800ps NReset = Reset; // FIXME: Removal time (01CLK -> 01R) is 281.25ps, but this needs to be 800 to prevent metastable value warnings
		input  Status;
		output Address, Input, Request, Full;
        endclocking
	
	task OutputAddress;
		input [7:0] Address;
	begin

		fcb.Address <= Address;
		fcb.Request <= 4'b0111;
		@fcb;
		Request = 4'b0000;
		##5;
	end
	endtask
	task ReadTest1;
	begin
		//TEST CASE 1
		TC = 1;
		fcb.NReset <= 0;
		##3; // wait 3 default cycles
		fcb.NReset <= 1;
		##1;
		$info("Test Case 1, Reset only");

		@(posedge RB);
		TC = 2;
		##1;
		fcb.Request <= 4'b0001;
		##30;
		OutputAddress(8'b01010101);	//Page address (Start): 010101 (21), block address: 0011010100 (212), page address (end): 010111 (23)
		OutputAddress(8'b11010100);
		//Output the third ROW address
		OutputAddress(8'b01010111);
		fcb.Request <=  4'b0001;
		##3;
	
		##1;
		##2;
	
		##2;		//TWB = 100ns
		##1195; 		//TR = 25us
	
		TC = 3;
		@(posedge WE_n);
		if (io == 8'h31) begin
			$info("Test Case 3.1), Command 31h as expected.");
		end
		else begin
			$error("Test Case 3.1, Command not as expected. Expecting 31h");
		end
	
		@(negedge RB)
		if (RE_n == 1 && WE_n == 1 && ALE == 0) begin
			$info("Test Case 3.2, All signals as expected.");
		end
		else begin
			$error("Test Case 3.2, Signals not as expected. Expecting CLE = 0, WE_n = 1, RE_n = 1");
		end
		FDataOE2 = '0;
		Full = '0;
		@(posedge RB);
		#21;	//TRR = 20ns
		if (RE_n == 0) begin
			$info("Test Case 3.3, TRR meets as expected.");
		end
		else begin
			$error("Test Case 3.3, tRR not as expected. Expecting tRR >= 20ns");
		end
	
		@(negedge RE_n);
		#25;
		@(negedge RE_n);
		if (RE_n == 0) begin
			$info("tRC meet as expected");
		end
		else
			$error("tRC does not meet as expected.");
		#50;
		//Testing Full Flag
		Full = '1;
		temp = io;
		#300;
		if (io == temp)
			$info("Test Case 3.4, Full flag asserted, state machine behaviors as expected");
		else
			$error("Test Case 3.4 Failed! Full flag asserted, but state machine is still reading from Flash Memory");
		Full = '0;
	
		//AddressReached(16'd1023, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 3.5, Maximum USB Data Packet Size Reached, Status signal as expected");
		else
			$error("Test Case 3.5 Failed, Maximum USB Data Packet Size Reached, Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd1023, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 3.6, Maximum USB Data Packet Size Reached second time, Status signal as expected");
		else
			$error("Test Case 3.6 Failed, Maximum USB Data Packet Size Reached second time, Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd18, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 3.7, First Page Read, Status signal as expected");
		else
			$error("Test Case 3.7 Failed, First Page Read Failed, Status signal not as expected");
	
		@ (posedge CLE);
		FDataOE2 = '1;	
		@ (posedge WE_n);
		if (io == 8'h31)
			$info("Test Case 3.8, command 31h received as expected");
		else
			$error("Test Case 3.8 Failed, command 31h not received as expected");
		#10;
		FDataOE2 = '0;
	
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 3.9, Maximum USB Data Packet Size Reached (Page 2), Status signal as expected");
		else
			$error("Test Case 3.9 Failed, Maximum USB Data Packet Size Reached (Page 2), Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd1023, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 4.0, Maximum USB Data Packet Size Reached second time (Page 2), Status signal as expected");
		else
			$error("Test Case 4.0 Failed, Maximum USB Data Packet Size Reached second time (Page 2), Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd18, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 4.1, Second Page Read, Status signal as expected");
		else
			$error("Test Case 4.1 Failed, Second Page Read Failed, Status signal not as expected");
	
		@ (posedge CLE);
		FDataOE2 = '1;	
		@ (posedge WE_n);
		if (io == 8'h31)
			$info("Test Case 4.2, command 31h received as expected");
		else
			$error("Test Case 4.2 Failed, command 3Fh not received as expected");
		#10;
		FDataOE2 = '0;	
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 4.3, Maximum USB Data Packet Size Reached (Page 3), Status signal as expected");
		else
			$error("Test Case 4.3 Failed, Maximum USB Data Packet Size Reached (Page 3), Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd1023, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 4.4, Maximum USB Data Packet Size Reached second time (Page 3), Status signal as expected");
		else
			$error("Test Case 4.4 Failed, Maximum USB Data Packet Size Reached second time (Page 3), Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd18, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 4.5, Third Page Read, Status signal as expected");
		else
			$error("Test Case 4.5 Failed, Third Page Read Failed, Status signal not as expected");
	
	
		##3;
		if (Status == '1)
			$info("Test Case 4.6, Status as expected");
		else
			$error("Test Case 4.6 Failed, Status not as expected. Expecting 111");	
		Request = '0;
		@ (posedge CLE);
		FDataOE2 = '1;	

	
	
		@ (posedge WE_n);
		FDataOE2 = '1;
		if (io == 8'hFF)
			$info("Test Case 4.7, command FFh received as expected");
		else
			$error("Test Case 4.7 Failed, command FFh not received as expected");
		#1100;
	end
	endtask

    	task EraseTest1;
   	begin
		fcb.NReset <= 0;
		##3; // wait 3 default cycles
		fcb.NReset <= 1;
		##1;
		@(posedge RB);
		TC = 6;
		$info("Test case 6 starts. Now testing Flash Memory Erase.");
		##1;
		fcb.Request <= 4'b0011;
		##30;
		OutputAddress(8'b01010101);	//Page address (Start): 010101 (21), block address: 0011010100 (212), page address (end): 010111 (23)
		OutputAddress(8'b11010100);
		OutputAddress(8'b01010111);
		fcb.Request <=  4'b0011;
		##3;
	
		##1;
		##2;
	
		##2;		//TWB = 100ns
		##1195; 		//TR = 25us
	
		TC = 3;
		@(posedge WE_n);
		if (io == 8'h31) begin
			$info("Test Case 6.1), Command 31h as expected.");
		end
		else begin
			$error("Test Case 6.1, Command not as expected. Expecting 31h");
		end
	
		@(negedge RB)
		if (RE_n == 1 && WE_n == 1 && ALE == 0) begin
			$info("Test Case 6.2, All signals as expected.");
		end
		else begin
			$error("Test Case 6.2, Signals not as expected. Expecting CLE = 0, WE_n = 1, RE_n = 1");
		end
		FDataOE2 = '0;
		Full = '0;
		@(posedge RB);
		#21;	//TRR = 20ns
		if (RE_n == 0) begin
			$info("Test Case 6.3, TRR meets as expected.");
		end
		else begin
			$error("Test Case 6.3, tRR not as expected. Expecting tRR >= 20ns");
		end
	
		@(negedge RE_n);
		#25;
		@(negedge RE_n);
		if (RE_n == 0) begin
			$info("Test Case 6.4, tRC meet as expected");
		end
		else
			$error("Test Case 6.4, tRC does not meet as expected.");
		#50;
		@ (posedge CLE);
		FDataOE2 = '1;	
		@ (posedge WE_n);
		if (io == 8'h31)
			$info("Test Case 6.5, command 31h received as expected");
		else
			$error("Test Case 6.5 Failed, command 31h not received as expected");
		#10;
		FDataOE2 = '0;
		@ (posedge CLE);
		FDataOE2 = '1;	
		@ (posedge WE_n);
		if (io == 8'h31)
			$info("Test Case 6.6, command 31h received as expected");
		else
			$error("Test Case 6.6 Failed, command 3Fh not received as expected");
		#10;
		FDataOE2 = '0;	
		@ (posedge CLE);
		FDataOE2 = '1;
		lcv = 3;
		while (lcv < 64) begin
		  @ (posedge WE_n);
		  $info("Already read %d page from flash memory.", lcv);
		  lcv += 1;
		  #10;
		  FDataOE2 = '0;
		  @ (posedge CLE);
		  FDataOE2 = '1;	
		end
		
		@ (posedge WE_n);
		$info("Already read %d page from flash memory.", lcv);
		if (io == 8'hFF)
			$info("Test Case 6.7, 64th page, command FFh received as expected");
		else
			$error("Test Case 6.7 Failed, 64th page, command FFh not received as expected");
		@ (posedge WE_n);
		$info("Now starts block erase operation");
		TC = 7;
		if (io == 8'h60)
			$info("Test Case 7.0, Command 60h received as expected");
		else
			$error("Test Case 7.0 Failed, did not receive command 60h");
		@ (posedge WE_n);
		$info("Test Case 7.1, Manually check address ROW1");
		@ (posedge WE_n);
		$info("Test Case 7.2, Manually check address ROW2");
		@ (posedge WE_n);
		if (io == 8'hD0)
			$info("Test Case 7.3, Command D0h received as expected");
		else
			$error("Test Case 7.3 failed. Command D0h not received as expected");

		@ (posedge WE_n);
		if (io == 8'h70)
			$info("Test Case 7.4, Command 70h received as expected");
		else
			$error("Test Case 7.4 failed. Command 70h not received as expected");
		
		@ (posedge RE_n);
		if (io == 8'h00)
			$info("Test Case 7.5, erase successfully!");
		else
			$warning("Test Case 7.5 failed, erase not successfully.");
		
		TC = 8;
		$info("Now starts cache program");
		lcv = 0;
		@(negedge WE_n);
		if (io == 8'h80)
			$info("Test Case 8.0, Command 80h received as expected");
		else
			$error("Test Case 8.0 failed, Command 80h did not receive as expected");

		@ (posedge WE_n);
		$info("Test Case 8.1, Manually check address COL1");
		@ (posedge WE_n);
		$info("Test Case 8.2, Manually check address COL2");
		@ (posedge WE_n);
		$info("Test Case 8.3, Manually check address ROW1");
		@ (posedge WE_n);
		$info("Test Case 8.4, Manually check address ROW2");
		@ (posedge WE_n);
		@ (posedge CLE);
		@ (posedge WE_n);
		if (io == 8'h15) begin
			$info("Test Case 8.5, command 15h received as expected");
			@ (posedge CLE);
			@ (posedge WE_n);
			if (io == 8'h70) begin
				#60;
				if (RE_n == 1)
					$info("tWHR meets");
				else
					$error("tWHR does not meet. Expecting at least 60ns");
				@(posedge RE_n);
				if (io == '0)
					$info("Successfully write page 1 into flash memory");
				else
					$error("Failed to write into flash memory");
			end

		end
		else
			$error("Test Case 8.5 Failed, command 15h not received as expected");
		
		lcv = 1;
		while (lcv < 21) begin
			@ (posedge CLE);
			@ (posedge CLE);
			@ (posedge CLE);
			@ (posedge WE_n);
			if (io == 8'h70) begin
				#60;
				@(posedge RE_n);
				if (io == '0)
					$info("Successfully write page %d into flash memory", lcv);
				else
					$error("Failed to write page %d into flash memory", lcv);
			end
			lcv += 1;
		end
		$info("*******************************************");
		$info("Already write page 0 to page 21 to the flash memory.");
		$info("Now starts write page 24 to page 63 to the flash memory.");
		lcv = 24;
		while (lcv < 64) begin
			@ (posedge CLE);
			@ (posedge CLE);
			@ (posedge CLE);
			@ (posedge WE_n);
			if (io == 8'h70) begin
				#60;
				@(posedge RE_n);
				if (io == '0)
					$info("Successfully write page %d into flash memory", lcv);
				else
					$error("Failed to write page %d into flash memory", lcv);
			end
			lcv += 1;
		end

		Request = '0;
		@ (posedge CLE);
		@ (posedge WE_n);
		if (io == '1) 
			$info("Erase successfully! Reset as expected.");
		else
			$warning("Erase may not perform successfuly.");


		
	end
	endtask
	
	task ReadTest2;
	begin
		TC = 4;
		##1;
		fcb.Request <= 4'b0001;
		##30;
		OutputAddress(8'b01010111);	//Page address (Start): 010111 (23), block address: 0011010100 (212), page address (end): 010111 (23)
		OutputAddress(8'b11010100);
		//Output the third ROW address
		OutputAddress(8'b01010111);
		fcb.Request <=  4'b0001;
		##2;		//TWB = 100ns
		##800; 	//TR <= 25us
		TC = 5;
		@(posedge WE_n);
		if (io == 8'h31) begin
			$info("Test Case 5.1, Command 31h as expected.");
		end
		else begin
			$error("Test Case 5.1, Command not as expected. Expecting 31h");
		end
	
		@(negedge RB)
		if (RE_n == 1 && WE_n == 1 && ALE == 0) begin
			$info("Test Case 5.2, All signals as expected.");
		end
		else begin
			$error("Test Case 5.2, Signals not as expected. Expecting CLE = 0, WE_n = 1, RE_n = 1");
		end
		FDataOE2 = '0;
		Full = '0;
		@(posedge RB);
		#21;	//TRR = 20ns
		if (RE_n == 0) begin
			$info("Test Case 5.3, TRR meets as expected.");
		end
		else begin
			$error("Test Case 5.3, tRR not as expected. Expecting tRR >= 20ns");
		end
	
		@(negedge RE_n);
		#25;
		@(negedge RE_n);
		if (RE_n == 0) begin
			$info("tRC meet as expected");
		end
		else
			$error("tRC does not meet as expected.");
		#50;
		//Testing Full Flag
		Full = '1;
		temp = io;
		#300;
		if (io == temp)
			$info("Test Case 5.4, Full flag asserted, state machine behaviors as expected");
		else
			$error("Test Case 5.4 Failed! Full flag asserted, but state machine is still reading from Flash Memory");
		Full = '0;
	
		//AddressReached(16'd1023, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 5.5, Maximum USB Data Packet Size Reached, Status signal as expected");
		else
			$error("Test Case 5.5 Failed, Maximum USB Data Packet Size Reached, Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd1023, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 5.6, Maximum USB Data Packet Size Reached second time, Status signal as expected");
		else
			$error("Test Case 5.6 Failed, Maximum USB Data Packet Size Reached second time, Status signal not as expected");
		#100;
		Request = 4'b1000;
		#20;
		Request = 4'b0001;
		//AddressReached(16'd18, Byte);
		@(negedge Status[0])
		if (Status == 4'b0100)
			$info("Test Case 5.7, First Page Read, Status signal as expected");
		else
			$error("Test Case 5.7 Failed, First Page Read Failed, Status signal not as expected");
		@ (posedge CLE);
		FDataOE2 = '1;	
	
		@ (posedge WE_n);
		if (io == 8'hFF)
			$info("Test Case 5.8, command FFh received as expected");
		else
			$error("Test Case 5.8 Failed, command FFh not received as expected");
		
	end
	endtask

    initial
	begin
		//ReadTest1();
		//ReadTest2();
		EraseTest1();
		
	
	end
	
	
endmodule

