// $Id: $
// File name:   onchipSRAM.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Obsolete wrapper file for on_chip_sram
module onchipSRAM
(
 input wire clk2,
 input wire NReset,
 output wire [15:0] OSDatain,
 input wire [15:0] OSDataout,
 input wire [11:0] OSAdd,
 input wire OSRead,
 input wire OSWrite
);




/*reg tb_mem_clr					= 0;
reg tb_mem_init					= 0;
reg tb_mem_dump					= 0;
reg tb_verbose					= 0;
reg tb_init_file_number	= 0;
reg tb_dump_file_number	= 0;
reg tb_start_address		= 0;
reg tb_last_address			= 0;*/
wire [12:0] Add = {1'b0, OSAdd};
reg [31:0] tb_init_file_number = '0;


on_chip_sram_wrapper OnChipSRAM
	(
		// Test bench control signals
		.mem_clr('0), //clear the entire block
		.mem_init('0), //initialize the memory
		.mem_dump('0), //dumping to the file
		.verbose('0), //dk
		.init_file_number(tb_init_file_number), //file numbers
		.dump_file_number('0),
		.start_address('0), //address range for dumping
		.last_address('0),
		// Memory interface signals
		.read_enable(OSRead), //to read
		.write_enable(OSWrite), //to write
		.address(Add), //to read/write
		.write_data(OSDataout), //input into onchip sram
	        .read_data(OSDatain) //output from onchip sram
        );

endmodule 
