// $Id: $
// File name:   OSCU.sv
// Created:     11/15/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: where two 8 bits data gets concatenated and put into on-chip SRAM
module OSCU
(
 input wire clk2,
 input wire NReset,
 input wire [2:0]AHOpcode,	
 input wire [9:0] block_address,
 input wire [5:0] start_address,
 input wire [5:0] end_address,
 input wire [15:0] OSDatain,
 output reg Dirty,
 output reg Done,
 output reg [15:0] OSDataout,
 output reg [11:0] OSAdd,
 output reg OSRead,
 output reg OSWrite
);

 reg nextDirty;
 reg AddTimer_Ena;
 reg [6:0] Rollover_Value;
 reg clear;
 reg [6:0] startvalue;
 reg AddTimer_Rollover;
 reg [6:0] CurrentAdd;


 reg [4:0] state;
 reg [4:0] nextstate;
 reg [63:0] storage;
 reg [63:0] nextstorage;
 parameter [4:0] IDLE = 5'd0,
                 READ1 = 5'd1,
  		 READ2 = 5'd2,
                 READ3 = 5'd3,
                 READ4 = 5'd4,
                 READ5 = 5'd5,
                 READ6 = 5'd6,
                 READ7 = 5'd7,
                 READ8 = 5'd8,
                 WRITE1 = 5'd9,
                 WRITE2 = 5'd10,
                 WRITE3 = 5'd11,
                 WRITE4 = 5'd12,
                 WRITE5 = 5'd13,
                 WRITE6 = 5'd14,
                 WRITE7 = 5'd15,
                 WRITE8 = 5'd16,
                 WRITE9 = 5'd17,
                 WRITE10 = 5'd18,
                 WRITE11 = 5'd19,
                 ERASE1 = 5'd20,
                 ERASE2 = 5'd21,
                 ERASE3 = 5'd22,
                 TEST1 = 5'd23,
                 TEST2 = 5'd24,    
                 TERMINATION1 = 5'd25,
                 TERMINATION2 = 5'd26,
                 TERMINATION3 = 5'd27;
                 

  flex_counter_advanced #(.NUM_CNT_BITS(7),.RESET_BIT(0)) OSCU_Counter( .clk(clk2), .n_rst(NReset), .clear(clear), .count_enable(AddTimer_Ena), .rollover_val(Rollover_Value[6:0]), .count_out(CurrentAdd[6:0]), .rollover_flag(AddTimer_Rollover),.START_BIT(startvalue[6:0]));
  
 always_ff @(posedge clk2, negedge NReset) begin
        if(NReset == 0) begin
            state <= IDLE;
            storage <= '0;
            Dirty <= 0;
        end
        else begin
            state <= nextstate;
            storage <= nextstorage; 
            Dirty <= nextDirty;
        end
   end     

 always_comb begin
   Done = 0;
   nextstorage = storage;
   OSRead = 0;
   OSWrite = 0;
   OSAdd = {block_address,2'b00};
   nextDirty = Dirty;
   AddTimer_Ena = 0;
   Rollover_Value = end_address; 
   clear = 0;
   OSDataout = '0;
   startvalue = '0;
   nextstate = state;
   case(state)
      IDLE: begin
          Done = 0;
          nextstorage = storage;
          if(AHOpcode == 3'b010) begin
            nextstate = READ1;
          end
          else if (AHOpcode == 3'b100) begin
            nextstate = READ1;
          end
          else begin
            nextstate = IDLE;
          end
      end
      READ1: begin
          OSAdd = {block_address,2'b00};
          OSRead = 1'b1;
          nextstorage[15:0] = OSDatain[15:0];
          nextstorage[63:16] = storage[63:16];
          nextstate = READ2; 
      end
      READ2: begin
          OSAdd = {block_address,2'b00};
          OSRead = 1'b0;
          nextstorage[15:0] = OSDatain[15:0];
          nextstorage[63:16] = storage[63:16];
          nextstate = READ3; 
      end
     READ3: begin
          OSAdd = {block_address,2'b01};
          OSRead = 1'b1;
          nextstorage[31:16] = OSDatain[15:0];
          nextstorage[15:0] = storage[15:0];
          nextstorage[63:32] = storage[63:32];
          nextstate = READ4; 
      end
    READ4: begin
          OSAdd = {block_address,2'b01};
          OSRead = 1'b0;
          nextstorage[31:16] = OSDatain[15:0];
          nextstorage[15:0] = storage[15:0];
          nextstorage[63:32] = storage[63:32];
          nextstate = READ5;
      end
   READ5: begin
          OSAdd = {block_address,2'b10};
          OSRead = 1'b1;
          nextstorage[47:32] = OSDatain[15:0];
          nextstorage[31:0] = storage[31:0];
          nextstorage[63:48] = storage[63:48];
          nextstate = READ6;
     end
  READ6: begin
          OSAdd = {block_address,2'b10};
          OSRead = 1'b0;
          nextstorage[47:32] = OSDatain[15:0];
          nextstorage[31:0] = storage[31:0];
          nextstorage[63:48] = storage[63:48];
          nextstate = READ7;
     end
  READ7: begin
          OSAdd = {block_address,2'b11};
          OSRead = 1'b1;
          nextstorage[63:48] = OSDatain[15:0];
          nextstorage[47:0] = storage[47:0];
          nextstate = READ8;
     end
  READ8: begin
          clear = 1;
          startvalue = start_address;
          Rollover_Value = end_address + 1'b1;
          OSAdd = {block_address,2'b11};
          OSRead = 1'b0;
          nextstorage[63:48] = OSDatain[15:0];
          nextstorage[47:0] = storage[47:0];
          nextstate = TEST1;
        end
 TERMINATION1: begin  //25
          Done = 1;
          nextstate = IDLE;
      end
 TEST1: begin
         AddTimer_Ena = 0;
         startvalue = start_address;
         Rollover_Value = end_address + 1'b1;
         clear = 0;
          if(AddTimer_Rollover) begin
          nextstate = TERMINATION3;
          end
          else if(storage[CurrentAdd] == 1) begin
          nextstate = TERMINATION2;
          end
          else begin
          nextstate = TEST2;
          end
        end
 TEST2: begin
         startvalue = start_address;
         Rollover_Value = end_address + 1'b1;
         AddTimer_Ena = 1;
         clear = 0;
	  if(AddTimer_Rollover) begin
          nextstate = TERMINATION3;
          end
          else if(storage[CurrentAdd] == 1) begin
          nextstate = TERMINATION2;
          end
          else begin
          nextstate = TEST1;
          end
      end
 TERMINATION2: begin //26
          nextDirty = 1;
          Done = 1;
          if(AHOpcode == 3'b100) begin
             nextstate = ERASE1;
          end
          else if(AHOpcode == 3'b001) begin
             nextstate = WRITE1;
          end
          else begin
             nextstate = TERMINATION2;
          end
     end
 TERMINATION3: begin  //27
          nextDirty = 0;
          Done = 1;
          if(AHOpcode == 3'b100) begin
             nextstate = ERASE1;
          end
          else if(AHOpcode == 3'b001) begin
             nextstate = WRITE1;
          end
          else begin
             nextstate = TERMINATION3;
          end
     end
 WRITE1: begin  //9
         clear = 1;
         startvalue = start_address;
         Rollover_Value = end_address + 1;
         nextstate = WRITE2;      
      end
 WRITE2: begin  //10
         AddTimer_Ena = 0;
         startvalue = start_address;
         Rollover_Value = end_address + 1;
         if(AddTimer_Rollover) begin
          nextstate = WRITE4;
          end
          else begin
          nextstate = WRITE3; 
          end     
      end
 WRITE3: begin  //11
         AddTimer_Ena = 1;
         startvalue = start_address;
         Rollover_Value = end_address + 1;
         nextstorage[CurrentAdd] = 1'b1;
         if(AddTimer_Rollover) begin
          nextstate = WRITE4;
          end
          else begin
          nextstate = WRITE2; 
          end       
      end
 WRITE4: begin  //12
         Rollover_Value = end_address + 1;
         OSDataout = storage[15:0];
         OSAdd = {block_address,2'b00};
         OSWrite = 1'b1;
         nextstate = WRITE5;
      end
 WRITE5:begin   //13
         OSDataout = storage[15:0];
         OSAdd = {block_address,2'b00};
         OSWrite = 1'b0;
         nextstate = WRITE6;
      end
 WRITE6: begin   //14
         OSDataout = storage[31:16];
         OSAdd = {block_address,2'b01};
         OSWrite = 1'b1;
         nextstate = WRITE7;
      end
 WRITE7: begin   //15
         OSDataout = storage[31:16];
         OSAdd = {block_address,2'b01};
         OSWrite = 1'b0;
         nextstate = WRITE8;
      end
 WRITE8:begin    //16
         OSDataout = storage[47:32];
         OSAdd = {block_address,2'b10};
         OSWrite = 1'b1;
         nextstate = WRITE9;
      end
 WRITE9: begin    //17
         OSDataout = storage[47:32];
         OSAdd = {block_address,2'b10};
         OSWrite = 1'b0;
         nextstate = WRITE10;
      end
 WRITE10: begin   //18
         OSDataout = storage[63:48];
         OSAdd = {block_address,2'b11};
         OSWrite = 1'b1;
         nextstate = WRITE11;
      end
 WRITE11: begin   //19
         OSDataout = storage[63:48];
         OSAdd = {block_address,2'b11};
         OSWrite = 1'b0;
         nextstate = TERMINATION1;
      end
 ERASE1: begin  //20
         clear = 1;
         startvalue = start_address;
         Rollover_Value = end_address;
         nextstate = ERASE2;      
      end
 ERASE2: begin  //21
         AddTimer_Ena = 0;
         startvalue = start_address;
         Rollover_Value = end_address;
         nextstorage[CurrentAdd] = 1'b0;
         if(AddTimer_Rollover) begin
          nextstate = WRITE4;
          end
          else begin
          nextstate = ERASE3; 
          end     
      end
 ERASE3: begin  //22
         AddTimer_Ena = 1;
         startvalue = start_address;
         Rollover_Value = end_address;
         nextstorage[CurrentAdd] = 1'b0;
         if(AddTimer_Rollover) begin
          nextstate = WRITE4;
          end
          else begin
          nextstate = ERASE2; 
          end       
      end
    endcase
 end







                 
endmodule 
