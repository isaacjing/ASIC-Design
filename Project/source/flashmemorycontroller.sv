// $Id: $
// File name:   flashmemorycontroller.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: wrapper file for the entire flash memory controller.
module flashmemorycontroller
(
 input wire clk2, 
 input wire NReset,
 output wire [2:0] Status,
 output wire RE_n,
 output wire WE_n,
 output wire ALE,
 output wire CLE,
 output wire CE_n,
 output wire InputShift,
 output wire OutputShift,
 output wire [7:0] Output,
 output wire [7:0] FDataIn,
 output wire FDataOE,
 input wire [7:0] FDataOut,
 input wire RB,
 input wire [7:0] Address,
 input wire [7:0] Input,
 output wire OSRead,
 output wire OSWrite,
 output wire [15:0] OSDataout,
 input wire [15:0] OSDatain,
 output wire [11:0] OSAdd,
 input wire [3:0] Request,
 input wire Full,  // fcu in
 output wire WP_n,
 output reg [16:0] OFAdd,
 input wire [15:0] OFDatain,
 output reg OFRead,
 output wire OFWrite,
 output wire [15:0] OFDataout
);
 wire AddTimer_Clear;
 wire clear;
 wire ACC_Enable; // ACC1
 wire [5:0] CurrentAdd; // AT1
 wire ADDReached; // ACC1
 wire [11:0]End_address; //ACC1
 reg AddTimer_Ena; // AT2
 wire AddTimer_Rollover; // AT3
 wire [5:0]Rollover_Value;// AT4
 reg Dirty; // FCU1
 wire [2:0] AHOpcode; //FCU1
 wire [2:0]IPBCommand; //FCU1
 wire IPB_inputshift; //FCU1
 wire OPB_outputshift;
 wire [7:0]Command; //FCU1
 wire output_control;
 wire output_shift;
 wire [7:0] Out_SRAM;
 wire [7:0] In_SRAM;
 //reg [16:0] OFAdd;
 //wire [15:0] OFDatain;
 //wire [15:0] OFDataout;
 reg [7:0] FDATA;
 wire clearOFCU;
 wire OFCUload;
 wire WriteOFC;
 //reg OFRead;
 //wire OFWrite;
 wire [5:0] end_address;
 reg add_control;
 wire [5:0] start_address;
 wire [5:0] startvalue;
 wire [9:0] block_address;
 wire Done;
  
 addresscountercolumn ACC1 (.clk2(clk2), .NReset(NReset), .clear(clear), .End_address(End_address),.ADDReached(ADDReached), .ACC_Enable);
 
 addresstimer AT1 (.clk2(clk2), .NReset(NReset), .clear(AddTimer_Clear), .AddTimer_Ena(AddTimer_Ena), .Rollover_Value(Rollover_Value),.AddTimer_Rollover(AddTimer_Rollover),.CurrentAdd(CurrentAdd), .startvalue(startvalue));
 
 FCU fcu1 (.FDataOE, .clk(clk2),.n_reset(NReset),.Full(Full),.RequestIn(Request),.RB(RB),.ADDReached(ADDReached),.Address(Address),.AddTimer_Rollover(AddTimer_Rollover),.AddTimer_Ena(AddTimer_Ena), .Status(Status), .CurrentAdd(CurrentAdd), .Dirty(Dirty), 
           .Command(Command),.RE(RE_n),.WE(WE_n),.ALE(ALE),.CLE(CLE),.CE(CE_n),.WP(WP_n),.RolloverValue(Rollover_Value),.IPBCommand(IPBCommand),.EndAddress(End_address),.InputShift(InputShift),.OutputShift(OutputShift), .clearOFCU, .AddTimer_Clear(AddTimer_Clear),
           .IPB_inputshift(IPB_inputshift),.ACCEnable(ACC_Enable), .Output_control(output_control), .OPB_outputshift(OPB_outputshift), .WriteOFC_O(WriteOFC), .FDataOut(Output), .start_address, .end_address, .add_control(add_control), .startvalue(startvalue), .OFCUload, .AHOpcode(AHOpcode), .checkdone(Done), .block_address);

inputprocessblock ipb1(.clk2(clk2),.NReset(NReset),.Command(Command),.Address(Address),.Input(Input),.Out_SRAM(Out_SRAM),.IPBCommand(IPBCommand),.input_shift(IPB_inputshift),.FDataIn(FDataIn));

outputprocessblock opb1(.*,.Output_control(output_control), .Output(Output));

OSCU  oscu1(.clk2(clk2),.NReset(NReset),.AHOpcode(AHOpcode),.OSAdd(OSAdd),.OSRead(OSRead),.OSWrite(OSWrite),.OSDatain(OSDatain),.OSDataout(OSDataout),.Dirty,.Done(Done),.block_address,.end_address,.start_address);

OFCU ofcu1(.clk2(clk2),.NReset(NReset),.Out_SRAM(Out_SRAM),.In_SRAM(In_SRAM),.WriteOFC(WriteOFC),.OFAdd(OFAdd),.OFDatain(OFDatain),.OFDataout(OFDataout),.OFRead(OFRead),.OFWrite(OFWrite), .OPB_outputshift(OPB_outputshift), .end_address, .add_control, .clearOFCU, .OFCUload, .IPB_inputshift,.CurrentAdd);

//onchipSRAM onchipSRAM (.clk2(clk2),.NReset(NReset),.OSAdd(OSAdd),.OSRead(OSRead),.OSWrite(OSWrite),.OSDatain(OSDatain),.OSDataout(OSDataout));

//offchipSRAM offchipSRAM (.clk2(clk2),.NReset(NReset),.OFAdd(OFAdd),.OFDatain(OFDatain),.OFRead(OFRead),.OFWrite(OFWrite), .OFDataout(OFDataout));

endmodule

 
 
