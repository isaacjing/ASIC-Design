// $Id: $
// File name:   flex_counter.sv
// Created:     9/16/2015
// Author:      Jinsheng Zhu
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: A very fancy flex counter which can specify the starting value.

module flex_counter_advanced
#(
	parameter NUM_CNT_BITS = 4,
        parameter RESET_BIT = 0
)
(
        input wire [(NUM_CNT_BITS - 1):0] START_BIT,
	input wire clk,
	input wire n_rst,
	input wire clear,
        input wire count_enable,
	input wire [(NUM_CNT_BITS - 1):0] rollover_val,
        output wire [(NUM_CNT_BITS - 1):0] count_out,
        output wire rollover_flag        
);
        reg [(NUM_CNT_BITS - 1):0] temp1; //state
        reg [(NUM_CNT_BITS - 1):0] temp2;  //nextstate output
        reg temp3;  //future state of flag
        reg temp4;  //current state of flag
        assign count_out = temp1;
        assign rollover_flag = temp4 ;

/*
always @ (posedge clk, negedge n_rst) 
  begin
   if (n_rst==0) 
   begin
   temp1 <= 0; 
   end 
   else 
   begin
      if(clear)
      begin
       temp1 <= 0;
      end
      else 
      begin
    	    if (count_enable) 
   	    begin
  	        if (rollover_val <= temp1)
     		begin
     		temp1[(NUM_CNT_BITS - 1):0] <= 1;
          	end 
          	else
          	begin
          	temp1 <= temp1 +1;
          	end
            end
            else 
            begin
            temp1 <= temp1;
            end
      end
  end
   
end 
endmodule


*/
always_ff @ (posedge clk, negedge n_rst) 
  begin
     if (n_rst==0) 
     begin
     temp1 <= START_BIT; 
     temp4 <= 0;
     end 
     else 
     begin
     temp1 <= temp2;
     temp4 <= temp3;
     end 
end


always_comb
begin
  temp2 = START_BIT;
  temp3 = 0;  
 if(clear)
   begin
       temp2 = START_BIT;
       if(temp4 == 1)
       begin
       temp3 = 0;
       end
   end
   else 
   begin
        if (count_enable) 
        begin
          if (temp4 == 0)
          begin
          temp3 = 0;
          temp2 = temp1 + 1;
//          temp2[(NUM_CNT_BITS - 1):0] = {{NUM_CNT_BITS-1{1'b0}},1'b1};
          if(rollover_val == temp2)
          begin
          temp3 = 1;
          end
          end
        end else
        begin
        temp2 = temp1;
        end 
       if(temp4 == 1)
       begin
       temp2 = RESET_BIT;
       temp3 = 0;
       end
    end
       
end
endmodule
   
