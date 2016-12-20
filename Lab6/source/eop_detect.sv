// Verilog for ECE337 Lab 6
//EOP Detector Block for USB


module eop_detect
(
	input wire d_plus,
	input wire d_minus,
	output wire eop
);

	assign eop = (~d_plus) & (~d_minus);
endmodule
