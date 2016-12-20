// $Id: $
// File name:   offchipSRAM.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu, Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Obsolete wrapper for off_chip_sram
module offchipSRAM
(
 input wire clk2,
 input wire NReset,
 output wire [15:0] OFDatain,
 input wire [15:0] OFDataout,
 input wire [16:0]OFAdd,
 input wire OFRead,
 input wire OFWrite
);


wire [15:0] OFData;
assign OFDatain	= (OFRead == 1) ? OFData : 'z;
assign OFData	= (OFWrite == 1) ? OFDataout : 'z;


/*reg tb_mem_clr					= 0;
reg tb_mem_init					= 0;
reg tb_mem_dump					= 0;
reg tb_verbose					= 0;
reg tb_init_file_number	= 0;
reg tb_dump_file_number	= 0;
reg tb_start_address		= 0;
reg tb_last_address			= 0;*/
wire [17:0] Add = {1'b0, OFAdd};



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
		.address(Add), //to read/write
		.data(OFData) //actual bus data I/O
	);

endmodule 
