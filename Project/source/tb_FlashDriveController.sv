// $Id: $
// File name:   tb_FlashDriveController.sv
// Created:     9/2/2013
// Author:      foo
// Lab Section: 99
// Version:     1.0  Initial Design Entry
// Description: USB 1.0 receiver test bench, highest level of test bench

`timescale 1ns / 10ps

module tb_FlashDriveController();

	// Define parameters
	// basic test bench parameters
	localparam CLK_PERIODUSB = 10ns;
   	localparam CLK_PERIODFCU = 20ns;
	
	// Shared Test Variables
	reg tb_clk_usb = 1'b0;
	reg tb_clk_fcu = 1'b0;
	
	// Clock generation blocks
	always
	begin
		tb_clk_usb = 1'b0;
		//#(CLK_PERIODUSB/2.0);
		#5ns;
		tb_clk_usb = 1'b1;
		//#(CLK_PERIODUSB/2.0);
		#5ns;
	end

	always
	begin
		tb_clk_fcu = 1'b0;
		//#(CLK_PERIODFCU/2.0);
		#10ns;
		tb_clk_fcu = 1'b1;
		//#(CLK_PERIODFCU/2.0);
		#10ns;
	end	
	
	wire Plus;
	wire Minus;
	reg Plus_in;
	reg Minus_in;

	reg Plus_in_temp;
	reg Minus_in_temp;

	wire Plus_out;
	wire Minus_out;
	reg USBOE;
	reg [7:0] ExpectedOutput;
	reg [7:0] Output_Value;
	//reg [7:0] Address;
	reg Reset = 0;
	reg Reset2;
	reg ReadEnable;
	reg ReadFlag;
	reg Empty;
	reg Full;
	reg [7:0] FifoOut;
	reg [7:0] Snt_data;
	reg rcving;
	reg W_enable_e;
	reg Input_Enable;
	reg Error;
	//reg [3:0] Request;
	//reg [2:0] Status;
	integer TC;
	reg [7:0] ByteData;
	reg Output_Enable;
	reg [7:0] Out_Data;
	//reg [7:0] Rcv_data;
	reg R_enable_e;
	integer lcv1;
	integer lcv2;
	reg [2:0] TempData = 3'b010;

	reg [7:0] LoadDataTest;
	reg EmptyTest;
	wire ReadEnableTest;
	reg Loading;
	reg [7:0] fifo_input_test;
	reg [7:0] Out_Data_test;

	reg Last = 1;
	reg [3:0] Count = 0;

	reg FDataOE, ALE, CLE, CE_n, RE_n, WE_n, RB, WP_n, OFRead, OFWrite;
	reg [7:0] FDataIn, FDataOut;
	wire [7:0] io;
	reg [15:0] Byte;
	reg [16:0] OFAdd;
	wire [17:0] OFAddExtra;
	reg [15:0] OFDatain;
	reg [15:0] OFDataout;

	reg OSRead, OSWrite;
	reg [15:0] OSDatain, OSDataout;
	reg [11:0] OSAdd;
	wire [12:0] OSAddExtra;


	integer columncount;
	localparam [7:0] Sync = 8'b10000000;
	localparam [7:0] PIDSetup = 8'b11010010;
	localparam [7:0] Data0 = 8'b00111100;
	localparam [7:0] Data1 = 8'b10110100;
	localparam [7:0] PIDOut = 8'b00011110;
	localparam [7:0] PIDIn = 8'b10010110;
	
	FlashDriveController FlashDriveController(
	.clk1(tb_clk_usb), 
 	.clk2(tb_clk_fcu),
 	.NReset(Reset),
 	.Plus_in(Plus_in),
 	.Minus_in(Minus_in),
 	.Plus_out(Plus_out),
 	.Minus_out(Minus_out),
 	.USBOE(USBOE),
 	.FDataOE(FDataOE),
 	.ALE(ALE),
	.CLE(CLE),
	.CE_n(CE_n),
	.RE_n(RE_n),
	.WE_n(WE_n),
	.FDataIn(FDataIn),
	.FDataOut(FDataOut),
	.RB(RB),
	.WP_n(WP_n),
	//Connections towards off-chip SRAM
	.OFAdd(OFAdd),
	.OFDatain(OFDatain),
	.OFRead(OFRead),
	.OFWrite(OFWrite),
	.OFDataout(OFDataout),

	//Connections towards on-chip SRAm
	.OSRead(OSRead),
	.OSWrite(OSWrite),
	.OSDataout(OSDataout),
	.OSDatain(OSDatain),
	.OSAdd(OSAdd)
	);

/*******************************************************************************************************
	Connection of OFF-CHIP SRAM, ON-CHIP SRAM, and Lab 6 USB Receiver (NOT PART OF THE CHIP)
*******************************************************************************************************/
	tb_usb_receiver_lab6 LAB6RECEIVE(.clk(tb_clk_usb), .n_rst(Reset & Reset2), .d_plus(Plus_out), .d_minus(Minus_out), .r_enable(ReadFlag), .r_data(FifoOut), .full(), .empty(), .rcving(), .r_error());
	
	tb_flash Flash(
	.RE_n(RE_n),
	.WE_n(WE_n),
	.CLE(CLE),
	.ALE(ALE),
	.CE_n(CE_n),
	.WP_n(WP_n),
	.io(io),
	.RB(RB),
	.FDataOE(FDataOE),
	.Byte(Byte)	//For testing purpose only
	);
	

	
	assign Plus = ~USBOE ? Plus_in : Plus_out;
	assign Minus = ~USBOE ? Minus_in : Minus_out;
	assign io = FDataOE ? FDataIn: 'z;
	assign FDataOut = io;


	//offchipSRAM offchipSRAM (.clk2(clk2),.NReset(NReset),.OFAdd(OFAdd),.OFDatain(OFDatain),.OFRead(OFRead),.OFWrite(OFWrite), .OFDataout(OFDataout));


	assign OSAddExtra = {1'b0, OSAdd};
	assign OFAddExtra = {1'b0, OFAdd};
	on_chip_sram_wrapper OnChipSRAM
	(
		// Test bench control signals
		.mem_clr(1'b0), //clear the entire block
		.mem_init(1'b0), //initialize the memory
		.mem_dump(1'b0), //dumping to the file
		.verbose(1'b0), //dk
		.init_file_number(32'b0), //file numbers
		.dump_file_number(32'b0),
		.start_address(0), //address range for dumping
		.last_address(0),
		// Memory interface signals
		.read_enable(OSRead), //to read
		.write_enable(OSWrite), //to write
		.address(OSAddExtra), //to read/write
		.write_data(OSDataout), //input into onchip sram
	        .read_data(OSDatain) //output from onchip sram
        );
	
	wire [15:0] OFData;
	assign OFDatain	= (OFRead == 1) ? OFData : 'z;
	assign OFData	= (OFWrite == 1) ? OFDataout : 'z;
	assign OFAddExtra = {1'b0, OFAdd};
	
	off_chip_sram_wrapper OffChipSRAM
	(
		// Test bench control signals
		.mem_clr(1'b0), //clear the entire block
		.mem_init(1'b0), //initialize the memory
		.mem_dump(1'b0), //dumping to the file
		.verbose(1'b0), //dk
		.init_file_number(32'b0), //file numbers
		.dump_file_number(32'b0),
		.start_address(0), //address range for dumping
		.last_address(0),
		// Memory interface signals
		.read_enable(OFRead), //to read
		.write_enable(OFWrite), //to write
		.address(OFAddExtra), //to read/write
		.data(OFData) //actual bus data I/O
	);

	initial
	begin
		Reset = 0;
		Plus_in = 1;
		Minus_in = 0;
		ReadFlag = 0;
		#50;
		Start();
/****************************************************************************************************************
						       TEST CASE 1
					Host Requesting read one page from Flash
****************************************************************************************************************/
		TC = 1;
		$info("Start sending TOKEN for SETUP");
		Plus_in <= 0;
		Minus_in <= 1;
		Plus_in_temp = 1;
		Minus_in_temp = 0;
		//ShiftDataOut(Sync);
		//ShiftDataOut(PIDSetup);
		//ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		//ShiftDataOut(8'b00000000);	//ENDP[2:0] + CRC5	CRC: 01111
		//OutputEOP();
		//$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#40;



		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5	CRC: 01111
		OutputEOP();
		#20;

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000001);	//Host Requesting Read

		//ShiftDataOut(8'b01111110);		
		//ShiftDataOut(8'b01111111);



		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);



	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);	//CRC16: 11001100 01011010
		ShiftDataOut(8'b00110011);
		ShiftDataOut(8'b01011010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");

		#950;
		#640;
		
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 1.1 passed. ACK success received as expected");
		end
		else
			//$error("Test Case 1.1 failed. ACK does not receive as expected");

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000001);	//Host Requesting Read
		ShiftDataOut(8'b01010101);	//Address byte 1 //Page address (Start): 010101 (21), block address: 0011010100 (212), page address (end): 010101 (21)
		ShiftDataOut(8'b11010100);	//Address byte 2
		ShiftDataOut(8'b01010101);	//Address byte 3    //CRC16: 01110001 11001011
		ShiftDataOut(8'b10001110);
		ShiftDataOut(8'b11010011);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#1200;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 1.2 passed. ACK success received as expected");

		end
		else
			//$error("Test Case 1.2 failed. ACK does not receive as expected");

		ReadInput();

		#250;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();


		@(posedge WE_n);
		if (io == 8'h31) begin
			$info("Test Case 1.3, Flash receives command 31h as expected.");
		end
		else begin
			//$error("Test Case 1.3, Flash does not receive command as expected. Expecting 31h");
		end
		
		@(posedge RE_n);
		$info("Now flash will start output data onto RX FIFO OUT");

		//@(posedge USBOE);
		@(negedge USBOE);
		$info("Finished transmitting first 1023 bytes of data.");

		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting first ACK packet. Now, start transmitting second set up packet for second 1023 bytes of data");

		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts transmitting the second 1023 bytes from device to host.");
		
		@(negedge USBOE);
		$info("Second 1023 bytes received. Now send ACK from host");
		
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();

		$info("Finishing transmitting Second ACK packet. Now, start transmitting third set up packet for second 2112-1023-1023 = 66 bytes of data");
		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts reading transmitting the last 66 bytes from device to host.");

		@(negedge USBOE);

		$info("Last 66 bytes of this page have been received. Sending ACK from host now.");
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting third ACK packet.");
		$info("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::");
		$info("TEST CASE 1 FINISHED. START TEST CASE 2, READ 2 PAGES OF DATA");

/*****************************************************************************************************************
						Test case 2:
				Host requesting reading two pages from flash.
*****************************************************************************************************************/
		//Start();
		#800;
		TC = 2;
		$info("Start sending TOKEN for SETUP");
		Plus_in <= 0;
		Minus_in <= 1;
		Plus_in_temp = 1;
		Minus_in_temp = 0;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000001);	//Host Requesting Read
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);
		ShiftDataOut(8'b00110011);					//CRC16: 11001100 01011010
		ShiftDataOut(8'b01011010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");

		#930;
		#640;
		
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 2.1 passed. ACK success received as expected");

		end
		else
			//$error("Test Case 2.1 failed. ACK does not receive as expected");

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000001);	//Host Requesting Read
		ShiftDataOut(8'b01011100);	//Address byte 1 //Page address (Start): 11100 (28), block address: 0011010100 (212), page address (end): 11101 (29)
		ShiftDataOut(8'b11010100);	//Address byte 2
		ShiftDataOut(8'b01011101);	//Address byte 3		//CRC16: 11111010 11101000
		ShiftDataOut(8'b01011111);
		ShiftDataOut(8'b00010111);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#1200;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 2.2 passed. ACK success received as expected");

		end
		else
			//$error("Test Case 2.2 failed. ACK does not receive as expected");

		ReadInput();

		#250;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();


		@(posedge WE_n);
		if (io == 8'h31) begin
			$info("Test Case 2.3, Flash receives command 31h as expected.");
		end
		else begin
			//$error("Test Case 2.3, Flash does not receive command as expected. Expecting 31h");
		end
		
		@(posedge RE_n);
		$info("Now flash will start output data onto RX FIFO OUT");

		//@(posedge USBOE);
		@(negedge USBOE);
		$info("Finished transmitting first 1023 bytes of data.");

		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting first ACK packet. Now, start transmitting second set up packet for second 1023 bytes of data");

		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts transmitting the second 1023 bytes from device to host.");
		
		@(negedge USBOE);
		$info("Second 1023 bytes received. Now send ACK from host");
		
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();

		$info("Finishing transmitting Second ACK packet. Now, start transmitting third set up packet for second 2112-1023-1023 = 66 bytes of data");
		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts reading transmitting the last 66 bytes from device to host.");

		@(negedge USBOE);

		$info("Last 66 bytes of this page have been received. Sending ACK from host now.");
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting third ACK packet.");

		
		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts reading transmitting the fourth packet, 1023 bytes from device to host.");

		@(negedge USBOE);
		$info("Fourth packet, 1023 bytes of the second page have been received. Sending ACK from host now.");
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting Fourth ACK packet.");

		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts reading transmitting the fifth packet, 1023 bytes from device to host.");

		@(negedge USBOE);

		$info("Fourth packet, 1023 bytes of the second page have been received. Sending ACK from host now.");
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting fifth ACK packet.");


		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDIn);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();

		$info("Now starts reading transmitting the sixth packet, 66 bytes from device to host.");

		@(negedge USBOE);

		$info("Sixth packet, 66 bytes of the second page have been received. Sending ACK from host now.");
		#100;
		ShiftDataOut(Sync);
		ShiftDataOut(8'b00101101);
		OutputEOP();
		$info("Finishing transmitting sixth ACK packet.");


/**********************************************************************************
					Test Case 4
					Flash Memory Write
*//////////////////////////////////////////////////////////////////////////////////
	 #20;
	 TC = 4;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000010);	//Host Requesting Write
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);
		ShiftDataOut(8'b00000000);
		ShiftDataOut(8'b01011010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");
		
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 2.1 passed. ACK success received as expected");

		end
		

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000010);	//Host Requesting Read
		ShiftDataOut(8'b00010011);	//Address byte 1 //Page address (Start): 010011 (19), block address: 0111010100 (468), page address (end): 010111 (23)
		ShiftDataOut(8'b01110101);	//Address byte 2
		ShiftDataOut(8'b00010011);	//Address byte 3
		ShiftDataOut(8'b10010111);
		ShiftDataOut(8'b00100000);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 2.2 passed. ACK success received as expected");

		end
		

		ReadInput();
                @(negedge USBOE);
                #200;
                  //first data packet
		$info("THe initialization of the first data packet(1023 Byte)");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("start to send actual data");

		ShiftDataOut(Sync);
		ShiftDataOut(Data1);
                for(columncount = 0; columncount <= 12'd1022; columncount++) begin
                   ShiftDataOut(columncount[7:0]); 
                end
		ShiftDataOut(8'b10100000);
		ShiftDataOut(8'b00000000);
                OutputEOP();
                $info("Check the timing for the next package");
		#950;
                #640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 3.1 passed. ACK success received as expected");

		end
		

		ReadInput();
		#940;
                #500;
                //send the second data packet for the first operation
       		$info("THe initialization of the second data packet(1023 Byte)");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("start to send actual data");

		ShiftDataOut(Sync);
		ShiftDataOut(Data1);
                for(columncount = 0; columncount <= 12'd1022; columncount++) begin
                   ShiftDataOut(columncount[7:0]); 
                end
		ShiftDataOut(8'b10100000);
		ShiftDataOut(8'b00000000);
                OutputEOP();
                $info("Check the timing for the next package");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 3.2 passed. ACK success received as expected");

		end
		else
			//$error("Test Case 3.2 failed. ACK does not receive as expected");
                #1000;
                ReadInput();

       		$info("THe initialization of the third data packet(66 Byte)");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("start to send actual data");

		ShiftDataOut(Sync);
		ShiftDataOut(Data1);
                for(columncount = 0; columncount <= 12'd065; columncount++) begin
                   ShiftDataOut(columncount[7:0]); 
                end
		ShiftDataOut(8'b11011011);
		ShiftDataOut(8'b10111010);
                OutputEOP();
                $info("Check the timing for the next package");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 3.2 passed. ACK success received as expected");

		end

                ReadInput();
               
                #10000;
                Reset = 0;
                #100;
                Reset = 1;

                #100;
//the second operation , setup package

                $info("The second test case, start from here");
                TC = 4;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000010);	//Host Requesting Write
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);
		ShiftDataOut(8'b00000000);
		ShiftDataOut(8'b01011010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");
		
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 5.1 passed. ACK success received as expected");

		end
		

		ReadInput();

		
//the address packet of the second operation		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000010);	//Host Requesting Write
		ShiftDataOut(8'b00010011);	//Address byte 1 //Page address (Start): 010011 (19), block address: 0111010100 (468), page address (end): 010111 (23)
		ShiftDataOut(8'b01110101);	//Address byte 2
		ShiftDataOut(8'b00010011);	//Address byte 3
		ShiftDataOut(8'b10010111);
		ShiftDataOut(8'b00100000);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 5.2 passed. ACK success received as expected");

		end
		

		ReadInput();
                @(negedge USBOE);
                #200;
//first data packet
		$info("THe initialization of the first data packet(1023 Byte)");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("start to send actual data");

		ShiftDataOut(Sync);
		ShiftDataOut(Data1);
                for(columncount = 0; columncount <= 12'd1022; columncount++) begin
                   ShiftDataOut(columncount[7:0]); 
                end
		ShiftDataOut(8'b10100000);
		ShiftDataOut(8'b00000000);
                OutputEOP();
                $info("Check the timing for the next package");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 7.2 passed. ACK success received as expected");

		end
		

		ReadInput();
                #1000;
//The second data packet for the second operation
       		$info("THe initialization of the second data packet(1023 Byte)");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("start to send actual data");

		ShiftDataOut(Sync);
		ShiftDataOut(Data1);
                for(columncount = 0; columncount <= 12'd1022; columncount++) begin
                   ShiftDataOut(columncount[7:0]); 
                end
		ShiftDataOut(8'b10100000);
		ShiftDataOut(8'b00000000);
                OutputEOP();
                $info("Check the timing for the next package");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 7.3 passed. ACK success received as expected");

		end
		

                #800;
                ReadInput();

       		$info("THe initialization of the third data packet(66 Byte)");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("start to send actual data");

		ShiftDataOut(Sync);
		ShiftDataOut(Data1);
                for(columncount = 0; columncount <= 12'd065; columncount++) begin
                   ShiftDataOut(columncount[7:0]); 
                end
		ShiftDataOut(8'b11011011);
		ShiftDataOut(8'b10111010);
                OutputEOP();
                $info("Check the timing for the next package");
		#950;
		#640;
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 7.4 passed. ACK success received as expected");

		end
		

                ReadInput();
		#2500;
		Plus_in <= 1;
		Minus_in <= 0;
		//Start();
		
/****************************************************************************************************************
					Flash Memory Erase
****************************************************************************************************************/
		TC = 5;
		$info("Start sending TOKEN for SETUP");
		#50;
		ShiftDataOut(Sync);
		ShiftDataOut(PIDSetup);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		$info("Finished sending TOKEN for SETUP, start sending SETUP Packet");

		#20;
		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b10101010);
		ShiftDataOut(8'b00000011);	//Host Requesting Erase
		ShiftDataOut(8'b10101010);	
		ShiftDataOut(8'b01010100);	
		ShiftDataOut(8'b11000000);	
		ShiftDataOut(8'b11100101);
		ShiftDataOut(8'b10010000);
		ShiftDataOut(8'b10010001);	//CRC16: 00001000 01011001
		ShiftDataOut(8'b00010000);
		ShiftDataOut(8'b10011010);
		OutputEOP();
		$info("Finished sending SETUP Packet, expecting to start receiving ACK.");

		#950;
		#640;
		
		if(FifoOut == 8'b00101101) begin
			$info("Test Case 5.1 passed. ACK success received as expected");

		end
		

		ReadInput();
		
		#250;
		$info("Now start a Out Transaction containing addresses");
		ShiftDataOut(Sync);
		ShiftDataOut(PIDOut);
		ShiftDataOut(8'b10101010);	//ADDR, + ENDP[3]
		ShiftDataOut(8'b11110110);	//ENDP[2:0] + CRC5
		OutputEOP();
		
		$info("Address - setup finished, now starts actual address bytes");

		ShiftDataOut(Sync);
		ShiftDataOut(Data0);
		ShiftDataOut(8'b00000011);	//Host Requesting erase
		ShiftDataOut(8'b00010011);	//Address byte 1 //Page address (Start): 010101 (21), block address: 1101010001, page address (end): 010111 (23)
		ShiftDataOut(8'b01110101);	//Address byte 2
		ShiftDataOut(8'b00010011);	//Address byte 3	//CRC16: 01101001 00111011
		ShiftDataOut(8'b10010110);
		ShiftDataOut(8'b11011100);
		OutputEOP();
		$info("Finishing sending addresses/instructions, expecting receiving ACKs from the device");
		#900;
		#640;
		//if(FifoOut == 8'b00101101) begin
		//	$info("Test Case 5.2 passed. ACK success received as expected");

		//end
		//else
		//	$error("Test Case 5.2 failed. ACK does not receive as expected");

		//ReadInput();
		@(posedge WE_n);
		if (io == 8'h31) begin
			$info("Test Case 5.3, Flash receives command 31h as expected.");
		end
		
		@(posedge RB);
		$info("Now, starts reading the entire block from flash to off-chip SRAM. ");
		lcv1 = 1;
		while(lcv1 < 65) begin
			@(posedge WE_n);			
			$info("Finished Read Page %d of total 64 pages", lcv1);
			lcv1 += 1;
		end
		@(posedge WE_n);
		@(posedge WE_n);
		@(posedge WE_n);
		$info("All read finished");
		@(posedge WE_n);
		$info("Now starts erasing.");
		if (io == 8'hd0) begin
			$info("Test Case 5.4, Flash receives command d0h as expected.");
		end
		

		@(posedge WE_n);
		if (io == 8'h70) begin
			$info("Test Case 5.5, Flash receives command 70h as expected.");
		end

		@(posedge RE_n);
		if (io == 8'h00) begin
			$info("Test Case 5.6, Block has been successfully erased.");
		end
		

		$info("Now starts writing pages into the flash");
		lcv1 = 1;
		while(lcv1 < 65) begin
			@(posedge CLE);
			@(posedge WE_n);
			
			if(io == 8'h80) begin
				@(posedge WE_n);
				@(posedge WE_n);
				@(posedge WE_n);
				lcv2 = io[5:0];
				@(posedge CLE);
				@(posedge WE_n);
				if(io == 8'h15) begin
					@(posedge CLE);
					@(posedge RE_n);
					if(io == 8'h00)
						$info("Successfully written address %d into flash. This is the %d page written in", lcv2, lcv1);
				end
			end
			lcv1 += 1;
		end
		@(negedge USBOE);
		$info("Done erasing data! Congratulation!!");
		
		
		

	end
	
	task Start;
	begin
		Reset = 0;
		ReadEnable = 0;
		//#2ns;
		@(posedge tb_clk_usb);		
		Reset = 1;
		$info("Done Reset");
	end
	endtask
	
	task OutputEOP;
		integer lcv2;
	begin
		@(posedge tb_clk_usb);
		Plus_in = '0;
		Minus_in = '0;
		Plus_in_temp = '0;
		Minus_in_temp = '0;
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk_usb);
		end
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk_usb);
		end
		Plus_in = 1;
		Minus_in = 0;
		Plus_in_temp = 1;
		Minus_in_temp = 0;
		for (lcv2 = 0; lcv2 < 8; lcv2 ++)
		begin
			@(posedge tb_clk_usb);
		end
	end
	endtask

	/*task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
		reg [8:0] BitStuffedData;
		reg BitStuffed;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			if (TempData[lcv1] == Last)
				
		end
	end
	endtask*/

	task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
		reg BitStuffed;
		integer lcv1;
		integer lcv2;
	begin
		TempData = InputData;
		for(lcv1 = 0; lcv1 < 8; lcv1++)
		begin
			Plus_in = (TempData[lcv1] == 1'b1) ? Plus_in_temp : ~Plus_in_temp;
			Minus_in = (TempData[lcv1] == 1'b1) ? Minus_in_temp : ~Minus_in_temp; 
			Plus_in_temp = Plus_in;
			Minus_in_temp = Minus_in;
			if (TempData[lcv1] == 1'b1) begin
				Count += 1;
			end
			else
				Count = '0;
			
			for (lcv2 = 0; lcv2 < 8; lcv2 ++)
			begin
				@(posedge tb_clk_usb);
			end
			if (Count == 4'd6) begin
				Plus_in = ~Plus_in_temp;
				Minus_in = ~Minus_in_temp;

				Plus_in_temp = Plus_in;
				Minus_in_temp = Minus_in;
				for (lcv2 = 0; lcv2 < 8; lcv2 ++)
				begin
					@(posedge tb_clk_usb);
				end	
				Count = '0;
			end
			//TempData = TempData>>1;		
		end
	end
	endtask

	/*task Translate;
		input [7:0] InputData;
		reg [7:0] TempData;
		reg [8:0] Out;
		integer lcv;
	begin
		TempData = InputData;
		
	end
	endtask*/

	/*task ShiftDataOut;
		input [7:0] InputData;
		reg [7:0] TempData;
	begin
		TempData = InputData;
		LoadDataTest = TempData;
		Loading = 1;
		#10;
		Loading = 0;
		#70;
		#559;
	end
	endtask*/

	task ReadInput;
	begin
		ReadFlag = 1;
		#10;
		ReadFlag = 0;
		#1;
	end
	endtask //

endmodule // tb_flex_pts_sr_DUT

