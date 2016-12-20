//Flash simulating module, for testing only
`timescale 1ns/1ns 

module tb_flash(
	input reg RE_n, WE_n, CLE, ALE, CE_n, WP_n, 
	input wire FDataOE,
	inout reg [7:0] io, 
	output reg RB,
	output reg [15:0] Byte 
);

reg [7:0] dout;
reg OE = '0;
reg [7:0] Input;
reg [7:0] Add1;
reg [7:0] Add2;
reg [7:0] Add3;
reg [7:0] Add4;
reg [7:0] Command;
reg Read;
reg Write;
reg Erase;
reg Idle;
reg Stop;

int lcv = 0;
//assign io = OE ? dout : 'z;
//assign Input = io;
assign io = !FDataOE ? dout : 'z;
assign Input = io;

reg [7:0] temp = 8'd1;


  always_ff @ (posedge WE_n) begin
      if (CLE && ~CE_n && ~ALE) begin
	Read = 0;
	Write = 0;
	Erase = 0;
	Idle = 1;
        case(Input)
	   8'hFF: reset();
	   8'h00: read();
	   8'h60: erase();
	   8'h80: write();
	endcase
      end
  end


 task reset();
  OE = '0;
  RB = '0;
  #1000;
  RB = '1;
  Read = 0;
	Write = 0;
	Erase = 0;
	Idle = 0;
	Add1 = 'z;
	Add2 = 'z;
	Add3 = 'z;
	Add4 = 'z;
	Command = 'z;
 endtask
 task OutputData();
  OE = '1;
  Byte = '0;
  while (CLE == '0 && Byte < 2113) begin
	@(negedge RE_n or negedge WE_n);
	if(WE_n == 0) begin
		@(posedge WE_n);
		Command = Input;
		if(Command == 8'hff) begin
			reset();
			return;
		end
	end
	#3;
	dout = temp;
	temp += 1;
	Byte += 1;
  end
  OE = '0;
  dout = 'z;
 endtask

 task read();
  	Read = 1;
	Write = 0;
	Erase = 0;
	Idle = 0;
  RB = '1;
  OE = '0;
  @ (posedge WE_n);
  Add1 = Input;
  @ (posedge WE_n);
  Add2 = Input;
  @ (posedge WE_n);
  Add3 = Input;
  @ (posedge WE_n);
  Add4 = Input;
  @ (posedge WE_n);
  Command = Input;
  if (Command == 8'hff) begin
	  reset();
	  return;
  end
  #100; 	//TWB = 100ns
  RB = '0;
  #25000;
  RB = '1;
  @ (posedge WE_n);
  Command = Input;
  if (Command == 8'hff) begin
	  reset();
	  return;
  end
  while (Command == 8'h31 && WE_n != '0) begin
	#100	//TWB = 100ns
	RB = '0;
	#5000	//tCBSYR
	RB = '1;
	
	//Output Data
	OutputData();
	if(Command == 8'hff)
		return;
	Idle = 'z;
  	//@ (posedge CLE);
	//OE = '0;
  
	//@ (posedge WE_n);
	//Command = Input;
	if (Command == 8'h3F || Command == 8'h30)
	  #100; //TWB = 100ns
	else if (Command == 8'hff) begin
	  reset();
	  return;
	end
	else if(Command == 8'h60) begin
	  erase();
          return;
	end
  end
  
  if (Command == 8'h3F) begin
	#100;	//TWB = 100ns
	RB = '0;
	#5000;	//tCBSYR
	RB = '1;
	
	//Output Data
	OutputData();
  	@ (posedge CLE);
	OE = '0;
  end 
 endtask

 task erase();
	Read = 0;
	Write = 0;
	Erase = 1;
	Idle = 0;
	//@ (posedge WE_n);
	//Command = Input;
	@ (posedge WE_n);
	Add1 = Input;
	@ (posedge WE_n);
	Add2 = Input;
	@ (posedge WE_n);
	Command = Input;
	if (Command == 8'hD0) begin
		#100; //TWB = 100ns
		RB = 0;
		#3000000; //tBERS = 3ms
		RB = 1;
		@ (posedge WE_n);
		Command = Input;
		@ (negedge RE_n);
		#1;
		OE = '1;
		dout = '0;
		@ (posedge RE_n);
		dout = 'z;
		OE = '0;
	end
	return;
 endtask

 task write();
	Write = 1;
	Idle = 0;
	Read = 0;
	while (1) begin
		Byte = 0;
		@ (posedge WE_n);
		Add1 = io;
		@ (posedge WE_n);
		Add2 = io;
		@ (posedge WE_n);
		Add3 = io;
		@ (posedge WE_n);
		Add4 = io;
		Byte = 0;
		while (Byte < 2112) begin
			Byte += 1;
			@ (posedge WE_n);	
		end
		@ (posedge CLE);
		@ (posedge WE_n);
		Command = io;
		if (Command == 8'hff) begin
			reset();
			return;
		end
		#100; //TWB = 100ns
		RB = 0;
		#5000; //TCBSYW = 5us
		RB = 1;
		@(posedge CLE);
		@ (posedge WE_n);
		Command = io;
		if (Command == 8'h70) begin
			CheckStatus();
			@ (posedge CLE);
			@ (posedge WE_n);
			Command = io;
			if (Command == 8'hff) begin
				reset();
				return;
			end
		end
	end
	
 endtask

 task CheckStatus();
	//@ (negedge RE_n);
	#60;	//tWHR
	OE = '1;
	#20;	//tREA
	dout = '0;
	@ (posedge RE_n);
	#15;
	dout = 'z;
	OE = '0;
 endtask
 task WriteDataIn();
	temp = '0;
	while (temp < 2112) begin
	 	@ (posedge WE_n);
		temp += 1;
	end
 endtask
        specify
                specparam t_CLS = 10ns, t_CLH =5ns; // CLE
		specparam t_CS  = 20ns, t_CH = 5ns; // CE_n#
		specparam t_ALS = 10ns, t_ALH = 5ns; // ALE
		specparam t_DS  = 10ns, t_DH = 5ns; // io

		specparam t_WP_n  = 12ns, t_WH = 10ns; // Write enable minimum, maximum
		specparam t_WC = 25ns; // WE cycle minimums

                $width(negedge WE_n, t_WP_n);
                $width(posedge WE_n, t_WH);
		$period(negedge WE_n, t_WC);

                $setuphold(posedge WE_n, CE_n,t_CS,t_CH);
                $setuphold(posedge WE_n &&& ~CE_n, CLE,t_CLS,t_CLH);
                $setuphold(posedge WE_n &&& ~CE_n, ALE,t_ALS,t_ALH);
                $setuphold(posedge WE_n &&& ~CE_n, io,t_DS,t_DH);

                //$setuphold(posedge clk &&& ~oe_n, DQ,t_SU,t_H);
                // OE?
                //(posedge clk => DQ) = (t_ACCE_nSS,t_ACCE_nSS,0); 
                //( oe_n => DQ) = (0ns,0ns,3.1ns);
        endspecify


endmodule
