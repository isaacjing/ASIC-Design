// $Id: $
// File name:   OFCU.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: OFCU, where 2 8 bytes data gets concatenated and store into off-chip SRAM. Also, 16 bits of data can be seperated into two pieces and stores back to flash.
module OFCU
(
 input wire [5:0] CurrentAdd,
 input wire clk2,
 input wire NReset,
 input wire WriteOFC,
 input wire OPB_outputshift,
 input wire IPB_inputshift,
 input wire [5:0] end_address,
 input wire add_control,
 input wire [7:0] In_SRAM,
 input wire [15:0] OFDatain,
 input wire clearOFCU,
 input wire OFCUload,
 output wire [7:0] Out_SRAM,
 output wire [15:0] OFDataout,
 output wire [16:0] OFAdd,
 output reg OFRead,
 output wire OFWrite
);
  reg clear;
  reg [1:0] d1;
  reg [1:0] d2;
  reg d3;
  reg OfRead2;
  reg [16:0] countadd1;
  wire [16:0] countadd2;
  reg [16:0] startbit;
  reg clockdelay_next; 
  reg clockdelay_current;
  reg delayed_shift;
  always_ff@(posedge clk2, negedge NReset) begin
    if(NReset == 0) begin
      clockdelay_current <= 0;
      delayed_shift <= 0;
    end
    else begin
      clockdelay_current <= clockdelay_next; 
      delayed_shift <= OfRead2;
    end
  end
 assign clockdelay_next = OFWrite | OfRead2 ;  

 assign OFAdd = countadd2;
 assign startbit = (CurrentAdd * 1056) ;

    
 
 flex_counter_advanced #(.NUM_CNT_BITS(2),.RESET_BIT(0)) OFC1( .clk(clk2), .n_rst(NReset), .clear(clearOFCU), .count_enable(OPB_outputshift), .rollover_val(2'b10), .count_out(d1), .rollover_flag(OFWrite),.START_BIT(2'b00));

 flex_counter_advanced #(.NUM_CNT_BITS(17),.RESET_BIT(0))  OFC2( .clk(clk2), .n_rst(NReset), .clear(clearOFCU), .count_enable(clockdelay_current), .rollover_val(17'd67853), .count_out(countadd1), .rollover_flag(d3),.START_BIT(startbit));

 flex_counter_advanced #(.NUM_CNT_BITS(2),.RESET_BIT(0)) OFC3( .clk(clk2), .n_rst(NReset), .clear(clearOFCU), .count_enable(WriteOFC), .rollover_val(2'b11), .count_out(d2), .rollover_flag(OfRead2),.START_BIT(2'b01));

 shiftreg8to16 s8t16 (.clk2,.NReset,.shift_enable(OPB_outputshift),.eightbits(In_SRAM),.sixteenbits(OFDataout));
 shiftreg16to8 s16t8 (.clk2,.NReset,.shift_enable(delayed_shift),.sixteenbits(OFDatain),.eightbits(Out_SRAM),.load_enable(OFCUload));

/*always_comb begin
  if(WriteOFC == 0) begin
      countadd2 = countadd1;
  end
  else begin
      countadd2 = 17'd67853 - countadd1;
   end
end*/

//assign countadd2 = ~WriteOFC? (countadd1): (17'd67853 - countadd1);
assign countadd2 = ~WriteOFC? (countadd1): (countadd1);
assign OFRead = ~WriteOFC? (1'b0): (1'b1);

endmodule 
