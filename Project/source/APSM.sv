// $Id: $
// File name:   APSM.sv
// Created:     11/21/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: APSM, a small state machine which works under FCU. It handles and temporarily stores addresses receiving from USB transceiver.


module APSM
(
  input wire clk,
  input wire n_reset,
  input wire APSEnable,
  input wire Done,
  input wire [7:0] Address,
  input wire [3:0] Request,
  output wire [5:0] start_address,
  output wire [5:0] end_address,
  output wire [9:0] block_address,
  output wire [5:0] RolloverValue,
  output wire [3:0] APSMstate
);
  reg [5:0] s_next;
  reg [5:0] s_current;
  reg [5:0] e_next;
  reg [5:0] e_current;
  reg [9:0] blockad_current;
  reg [9:0] blockad_next;
  reg [3:0] state;
  reg [3:0] nextstate;
  reg [5:0] results;
  
  parameter [3:0] IDLE = 4'd0,
                  A1 = 4'd1,
                  A2 = 4'd2,
                  A3 = 4'd3,
                  A4 = 4'd4,
                  A5 = 4'd5,
                  A6 = 4'd6,
                  A7 = 4'd7;

  assign RolloverValue = results[5:0];
  assign start_address = s_current;
  assign end_address = e_current;
  assign block_address = blockad_current;
  assign APSMstate = state;

  always_ff @ (posedge clk, negedge n_reset) begin
   if(n_reset == 0) begin
      s_current <= 6'd0;
      e_current <= 6'd0;
      blockad_current <= 10'd0;
      state <= IDLE;
   end
   else begin
      s_current <= s_next;
      e_current <= e_next;
      blockad_current <= blockad_next;
      state <= nextstate;
   end
  end 
    



  always_comb begin
    e_next = e_current;
    s_next = s_current;
    blockad_next = blockad_current;
    nextstate = state;
    case(state)
      IDLE: begin
        if(APSEnable == 1) begin
         nextstate = A1;
        end
        else begin
         nextstate = IDLE;
        end
      end 
      A1: begin
       if(Request == 4'b0111) begin
         nextstate = A2;
       end
       else begin  
         nextstate = A1;
       end 
      end
     A2: begin 
      s_next[5:0] = Address[5:0];
      blockad_next[1:0] = Address[7:6];
      nextstate = A3;
     end
     A3: begin
      if(Request == 4'b0111) begin   
        nextstate = A4;
      end
      else begin
        nextstate = A3;
      end
     end
     A4:begin 
       nextstate = A5;
       blockad_next[9:2] = Address[7:0];
     end
     A5: begin
      if(Request == 4'b0111) begin
        nextstate = A6;
      end
      else begin
        nextstate = A5;
      end
     end
     A6: begin
        e_next[5:0] = Address[5:0];
        nextstate = A7;
     end
     A7: begin
        if(Done == '1) begin
         nextstate = IDLE;
        end
        else begin
         nextstate = A7;
        end
       end
     endcase
   end
 
    always_comb begin
     results = e_current - s_current + 1'b1;
    end
endmodule 
