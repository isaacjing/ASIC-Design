// $Id: $
// File name:   magnitude.sv
// Created:     9/20/2015
// Author:      Jiangshan Jing
// Lab Section: 337-04
// Version:     1.0  Initial Design Entry
// Description: Magnitude convertor

module magnitude
(
	input [16:0] in,
	output wire [15:0] out
);

/*reg [15:0] OutPut;
reg sign;

always
begin
	sign = in[16];
	if (sign == 1'b1) begin
		OutPut = (~in[15:0]) + 1;
		if (in[15:0] == '0) begin
			OutPut = '1;
		end
	end
	else if (sign == 1'b0)
		OutPut = in[15:0];
end*/

//assign out = (in[16:0] == 17'b10000000000000000) ? '1 : (in[16]?(131072 - in):in[15:0]);
assign out = (~in[16])? (in[15:0]):(in[15:0] == '0 ? 65535: 65536-in[15:0]);
endmodule
