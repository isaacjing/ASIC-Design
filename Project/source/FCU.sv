// $Id: $
// File name:   FCU.sv
// Created:     9/9/2015
// Author:      Jiangshan Jing, Jinsheng Zhu
// Lab Sectnext_ion: 337-04
// Versnext_ion:     1.0  Initial Design Entry
// Descriptnext_ion: Controller unit for the flash memory controller, a very big state machine.


module FCU
(
	input wire clk,
	input wire n_reset,
	input wire [3:0] RequestIn,
	input wire RB,
	input wire ADDReached,
	input wire AddTimer_Rollover,
	input wire Full,
        input wire Dirty,
        input wire [7:0] Address,
        input wire [7:0] FDataOut,
	input wire [5:0] CurrentAdd,
        input wire checkdone,
	output reg AddTimer_Ena,
	output reg [7:0] Command,
        //output reg counterclear,
        output reg [2:0] AHOpcode,
	output reg RE,
	output reg WE,
	output reg ALE,
	output reg CLE,
	output reg CE,
	output reg WP,
	output wire WriteOFC_O,
	output reg [5:0] RolloverValue,
	output reg [2:0] IPBCommand, 
        output reg Output_control,
	output reg [11:0] EndAddress,
        output reg OPB_outputshift,
	output reg InputShift,
	output reg OutputShift,
	output reg IPB_inputshift,
	output reg OFCUload,
	output reg ACCEnable,
	output reg [2:0] Status,
	output reg FDataOE,
        output reg [5:0] startvalue,
	output reg clearOFCU,
	output reg [5:0] end_address,
	output reg [5:0] start_address,
	output reg add_control,
	output reg AddTimer_Clear,
	output reg [9:0] block_address
);
reg [5:0] next_RolloverValue;
reg [5:0] next_startvalue;
reg [7:0] state;
reg [7:0] nextstate;
reg OutputShift_nxt;
reg APSEnable;
reg Done;
reg next_add_control;
reg [5:0] APSMRollOverValue;
reg WriteOFC;
reg [3:0] APSMstate;
reg [11:0] next_EndAddress;
reg [3:0] Request;
reg [3:0] next_Request;


assign WriteOFC_O = WriteOFC;


reg next_FDataOE;
reg next_WE;
reg next_CE;
reg next_CLE;
reg next_ALE;
reg next_RE;

//assign add_control_out = add_control;

parameter [7:0] IDLE = 8'd0,
		COMMANDWRITE1 = 8'd1,
		COMMANDWRITE2 = 8'd2,
		COMMANDWRITE3 = 8'd3,
		COMMANDWRITE4 = 8'd4,
		RBWRITE1 = 8'd5,
		RBWRITE2 = 8'd6,
                COMMANDWRITE5 = 8'd7,
                COMMANDWRITE6 = 8'd8,
                
//erase states
                ECOMMANDWRITE1 = 8'd10,
		ECOMMANDWRITE2 = 8'd11,
		ECOMMANDWRITE3 = 8'd12,
		ECOMMANDWRITE4 = 8'd13,
		ERBWRITE1 = 8'd14,
		ERBWRITE2 = 8'd15,
                ECOMMANDWRITE5 = 8'd16,
                ECOMMANDWRITE6 = 8'd17,
                ECOMMANDWRITE7 = 8'd18,
                ECOMMANDWRITE8 = 8'd19,
                ECOMMANDWRITE9 = 8'd20,
                ECOMMANDWRITE10 = 8'd21,
                ERBWRITE3 = 8'd22,
                ERBWRITE4 = 8'd23,
                
                ECOMMANDWRITE11 = 8'd24,
                ECOMMANDWRITE12 = 8'd25,
                EWAIT1 = 8'd26,
                EWAIT2 = 8'd27,
                EWAIT3 = 8'd28,
                ECHECK1 = 8'd29,
                ECHECK2 = 8'd30,
                ECHECK3 = 8'd31,
                EWAIT4  = 8'd32,
                
                
                EAD1 = 8'd33,
                EAD1NEXT = 8'd34,
                EAD2 = 8'd35,
                EAD2NEXT = 8'd36,
                EADWRITE1 = 8'd37,
                EADWRITE1NEXT = 8'd38,
                EADWRITE2 = 8'd39,
                EADWRITE2NEXT = 8'd40,
                EADWRITE3 = 8'd41,
                EADWRITE3NEXT = 8'd42,
                EADWRITE4 = 8'd43,
                EADWRITE4NEXT = 8'd44,
                EDATATERMINATED1 = 8'd45,
		

                
      


		ADDOUTPUT1 = 8'd50,
		ADDOUTPUT1NEXT = 8'd51,
		ADDOUTPUT2 = 8'd52,
		ADDOUTPUT2NEXT = 8'd53,
		ADDWAIT3 = 8'd54,
		ADDREAD3 = 8'd55,
		ADDREAD3NEXT = 8'd56,
		ADDWAIT4 = 8'd57,
		ADDREAD4 = 8'd58,
		ADDREAD4NEXT = 8'd59,
		
		EADDOUTPUT1 = 8'd60,
		EADDOUTPUT1NEXT = 8'd61,
		EADDOUTPUT2 = 8'd62,
		EADDOUTPUT2NEXT = 8'd63,
		EADDWAIT3 = 8'd64,
		EADDREAD3 = 8'd65,
		EADDREAD3NEXT = 8'd66,
		EADDWAIT4 = 8'd67,
		EADDREAD4 = 8'd68,
		EADDREAD4NEXT = 8'd69,
		

		DATAREAD1A = 8'd80,
		DATAREAD2A = 8'd81,
		DATAREADWAIT1A = 8'd82,
		DATAREADWAIT2A = 8'd83,

		DATAREAD1B = 8'd84,
		DATAREAD2B = 8'd85,
		DATAREADWAIT1B = 8'd86,
		DATAREADWAIT2B = 8'd87,


		DATAREAD1C = 8'd88,
		DATAREAD2C = 8'd89,
		DATAREADWAIT1C = 8'd90,
		DATAREADWAIT2C = 8'd91,
		DATATERMINATED1 = 8'd95,
		DATATERMINATED2 = 8'd96,
                DATATERMINATED3 = 8'd97,
		TERMINATEWAIT1 = 8'd98,
		TERMINATEWAIT2 = 8'd99,
                EDATAREAD1 = 8'd100,
		EDATAREAD2 = 8'd101,
		EDATAREADWAIT1 = 8'd102,
		EDATAREADWAIT2 = 8'd103,     
		ETERMINATEWAIT1 = 8'd104,
		ETERMINATEWAIT2 = 8'd105,
		ECOMMANDWRITE13 = 8'd120,
                ECOMMANDWRITE14 = 8'd121,
                EDATAPREPARE1 = 8'd122,
                EDATAPREPARE2 = 8'd123,
                EDATAPREPARE3 = 8'd124,
                EDATAPREPARE4 = 8'd125,
                EDATAWRITE1 = 8'd126,
                EDATAWRITE2 = 8'd127,
                EDATAPREPARE5 = 8'd128,
                ECOMMANDWRITE15 = 8'd129,
                ECOMMANDWRITE16 = 8'd130,
                ERBWRITE5 = 8'd131,
                ERBWRITE6 = 8'd132,
                ECOMMANDWRITE17 = 8'd133,
                ECOMMANDWRITE18 = 8'd134,
                EWAIT5 = 8'd135,
                EWAIT6 = 8'd136,
                EWAIT7 = 8'd137,
                ECHECK4 = 8'd138,
                ECHECK5 = 8'd139,
	        ECHECK6 = 8'd140,
                EWAIT8 = 8'd141,
                EMASKCHECK1 = 8'd142,
                EMASKCHECK2 = 8'd143,
                EMASKCHECK3 = 8'd144,
		ECHECK7 = 8'd145,
		ERASEACKSUCCESS = 8'd146,
		EDRIDLE = 8'd200,
                EADDCOUNTERSETUP1 = 8'd201,	
		ERESET1 = 8'd202,
		ERESET2 = 8'd203,
		ERESET3 = 8'd204,
	        EERRORCOMMAND2 = 8'd205,
		EERRORTERMINATED2 = 8'd206,
		EDATAWRITE3 = 8'd207,
		EDATAWRITE4 = 8'd208,
		DRIDLE = 8'd239,            
		ADDCOUNTERSETUP1 = 8'd240,
                ADDCOUNTERSETUP2 = 8'd241,
                ADDCOUNTERSETUP3 = 8'd242,
		ERRORCOMMAND = 8'd250,
		ERRORTERMINATED = 8'd251,
		RESET4 = 8'd252,
                RESET3 = 8'd253,
                RESET2 = 8'd254,
                RESET1 = 8'd255,
//write state  
                DIRTYCHECK1 = 8'd150,
                DIRTYCHECK2 = 8'd151,
                WRITEERASEAD1 = 8'd152,
                WRITEERASEAD1NEXT = 8'd153,
                WRITEERASEAD2 = 8'd154,
                WRITEERASEAD2NEXT = 8'd155,
                WRITEERASEAD3 = 8'd156,
                WRITEERASEAD3NEXT = 8'd157,
                WRITEERASEAD4 = 8'd158,
                WRITEERASEAD4NEXT = 8'd159,
                WRITEWAITAD1 = 8'd160,
                WRITEWAITAD2 = 8'd161,
                WCOMMANDWRITE1 = 8'd162,
                WCOMMANDWRITE2 = 8'd163,
                WCOMMANDWRITE3 = 8'd164,
                WCOMMANDWRITE4 = 8'd165,
                WRBWRITE1 = 8'd166,
                WRBWRITE2 = 8'd167,
                WCOMMANDWRITE5 = 8'd168,
                WCOMMANDWRITE6 = 8'd169,
                WRITETERMINATED = 8'd170,
                WADDCOUNTERSETUP1 = 8'd171,
                WDATAREAD1A = 8'd172,
                WDATAREAD2A = 8'd173,
                WDATAREADWAIT1A = 8'd174,
                WDATAREADWAIT2A = 8'd175,
                WDATATERMINATED1 = 8'd176, 
                WADDCOUNTERSETUP2 = 8'd177,
                WDATAREAD1B = 8'd178,
                WDATAREAD2B = 8'd179,
                WDATAREADWAIT1B = 8'd180,
                WDATAREADWAIT2B = 8'd181,
                WDATATERMINATED2 = 8'd182, 
                WADDCOUNTERSETUP3 = 8'd183,
                WDATAREAD1C = 8'd184,
                WDATAREAD2C = 8'd185,
                WDATAREADWAIT1C = 8'd186,
                WDATAREADWAIT2C = 8'd187,
                WDATATERMINATED3 = 8'd188, 
                DIRTYUPDATE1 = 8'd189,
                DIRTYUPDATE2 = 8'd190,

		DATATERMINATED1_NXT = 8'd237,
		DATATERMINATED2_NXT = 8'd238,
		
		//extre state, dont comment out
                WEADWRITE1 = 8'd191,
                WEADWRITE1NEXT = 8'd192,
                WEADWRITE2 = 8'd193,
                WEADWRITE2NEXT = 8'd194,
                WEADWRITE3 = 8'd195,
                WEADWRITE3NEXT = 8'd196,
                WEADWRITE4 = 8'd197,
                WEADWRITE4NEXT = 8'd198,
//make up dummy states
		PREECOMMANDWRITE2 = 8'd214,
		ADDREAD4NEXT_2 = 8'd215,
		PREADDREAD4 = 8'd216,
		AFTERCOMMANDWRITE3 = 8'd217,
		PRECOMMANDWRITE1 = 8'd218,
		PRETERMINATEWAIT = 8'd219,
                WDATAREADDUMMY1 = 8'd220,
                WDATAREADDUMMY2 = 8'd221,
                WDATAREADDUMMY3 = 8'd222,
                DIRTYUPDATE = 8'd224,
                WDUMMY1 = 8'd225,
                WDUMMY2 = 8'd226,
                WDUMMY3 = 8'd227,
                WWAIT5 = 8'd228,
                WWAIT6 = 8'd229,
                WWAIT7 = 8'd230,
                WCHECK4 = 8'd231,
                WCHECK5 = 8'd232,
	        WCHECK6 = 8'd233,
                WWAIT8 = 8'd234,
		WCHECK7 = 8'd235,
                W1 = 8'd236,
                W2 = 8'd223,
                W3 = 8'd245;

APSM APSM1(.clk,.n_reset,.Address,.Request,.RolloverValue(APSMRollOverValue), .APSEnable, .Done, .block_address,.end_address,.start_address, .APSMstate
);

always_ff @ (posedge clk, negedge n_reset)
  begin:StateReg
    if(n_reset == 1'b0)
    begin      
                FDataOE <= 0;
                startvalue <= 0;
		state <= RESET1;
		OutputShift <= 0;
		add_control <= 0;
                EndAddress <= 0;
		WE <=  1;
		CE <=  1;
		CLE <= 0;
		ALE <= 0;
		RE <= 1;
                RolloverValue<= 0; 
                Request <= '0;
    end
    else
    begin
                FDataOE <= next_FDataOE;
		startvalue <= next_startvalue;
                state <= nextstate;
		OutputShift <= OutputShift_nxt;
                add_control <= next_add_control;
                EndAddress <= next_EndAddress;
		WE <=  next_WE;
		CE <=  next_CE;
		CLE <= next_CLE;
		ALE <= next_ALE;
		RE <= next_RE;
                RolloverValue <= next_RolloverValue;
                Request <= next_Request;
    end
  end

always_comb 
begin: Next_State
//Default values:
	next_Request = RequestIn;
        next_add_control = add_control;
	nextstate = state;
	IPBCommand = 3'b000;
	IPB_inputshift = 1'b0;
	WriteOFC = 0;
	OutputShift_nxt = '0;
	//next_add_control = 0;
	next_CE = '0;
	WP = '1;
        Command = '0;
        clearOFCU = '0;
        next_RE = '1;
        next_CLE = '0;
        next_ALE = '0;
	next_WE = '1;
	next_RolloverValue= RolloverValue;
	next_FDataOE = '1;
	AddTimer_Ena = '0;
	AddTimer_Clear = 0;
        Done = '0;
        APSEnable ='0;
        OFCUload = 0;
	next_startvalue = '0;
	AHOpcode = '0;
        Status = '0; //May need to delete...
	APSEnable = '0;
	Output_control = '0;
	OPB_outputshift = '0;
	InputShift = '0;
	ACCEnable = '0;
	next_EndAddress = EndAddress;
	case (state)
	RESET1: begin
		next_FDataOE = 1;
		next_CLE = '1;
		next_CE = '0;
		next_WE = '0;
		next_ALE = '0;
		Status = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		nextstate = RESET2;
	end
	RESET2: begin
		next_FDataOE = 1;
		next_CLE = '1;
		next_CE = '0;
		next_WE = '0;
		next_ALE = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		nextstate = RESET3;
	end
	RESET3: begin
		next_WE = '1;
		next_CLE = '1;
		next_CE = '0;
		next_ALE = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		Status = '1;
		nextstate = RESET4;
	end
	RESET4: begin
		next_WE = '1;
		next_CLE = '1;
		next_CE = '0;
		next_ALE = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		Status = '1;
		nextstate = IDLE;
	end

	IDLE: begin
		next_CE = '1;
		next_add_control = 0;
		if (Request == 4'b0001) begin
	  		nextstate = PRECOMMANDWRITE1;
		end
		else if(Request == 4'b0011) begin	//Erase
                        nextstate = ECOMMANDWRITE1;
                        next_WE = 0;
                        next_CLE = 1;
			next_CE = 0;
                end
                else if(Request == 4'b0010) begin
                        nextstate = WRITEWAITAD1;
                end
                else begin
			nextstate = IDLE;
		end
    	end
	COMMANDWRITE1: begin
                APSEnable = '1;
		Command = '0;
		next_WE = '0;
		next_CLE = '1;
		next_CE = '0;
		IPBCommand = 3'b100;
		nextstate = COMMANDWRITE2;
	end
	COMMANDWRITE2: begin
		Command = '0;
		next_WE = '1;
		next_CE = '0;
		next_CLE = '1;
                IPBCommand = 3'b100;
		nextstate = ADDOUTPUT1;
	end
    	ADDOUTPUT1: begin   //50
		IPBCommand = 3'b100;
		next_WE = '0;
		next_CLE = '0;
		next_CE = '0;
                Command = '0;
                next_ALE = '1;
	        nextstate = ADDOUTPUT1NEXT;
	end
	ADDOUTPUT1NEXT: begin //51
		next_WE = '1;
                next_CLE = '0;
		next_CE = '0;
		Command = '0;
		IPBCommand = 3'b100;
		next_ALE = '1;
	        nextstate = ADDOUTPUT2;
	end
	ADDOUTPUT2: begin //52
		next_WE = '0;
		IPBCommand = 3'b100;
		next_ALE = '1;
                next_CLE = '0;
		next_CE = '0;
		Command = '0;
                nextstate = ADDOUTPUT2NEXT;
	end
	PRECOMMANDWRITE1: begin
		APSEnable = '1;
		Command = '0;
		next_WE = '0;
		next_CLE = '1;
		next_CE = '0;
		IPBCommand = 3'b100;
		nextstate = COMMANDWRITE1;
	end
	ADDOUTPUT2NEXT: begin //53
		next_WE = '1;
		IPBCommand = 3'b100;
		next_ALE = '1;
		next_CE = '0;
                next_CLE = '0;
		Command = '0;
		nextstate = ADDWAIT3;
	end
        ADDWAIT3: begin  //54
		IPBCommand = 3'b010;
		next_WE = '1;
		next_ALE = '1;
		next_CE = '0;
		IPB_inputshift = '0;
		if (Request == 4'b0111) begin
			nextstate = ADDREAD3;
		end
		else begin
			nextstate = ADDWAIT3;
                end
	end
	ADDREAD3: begin //55
		next_WE = '0;
		IPBCommand = 3'b010;
		next_ALE = '1;
		next_CE = '0;
		IPB_inputshift = '1;
	        nextstate = ADDREAD3NEXT;
	end
	ADDREAD3NEXT: begin  //56
		next_WE = '1;
		IPBCommand = 3'b010;
		next_ALE = 1;
		next_CE = '0;
		IPB_inputshift = 0;
		nextstate = ADDWAIT4;
	end
	ADDWAIT4: begin   //57
		IPBCommand = 3'b010;
		next_WE = '0;
		next_CE = '0;
		next_ALE = '1;
		IPB_inputshift = '0;
		if (Request == 4'b0111) begin
			nextstate = PREADDREAD4;
		end
		else begin
			nextstate = ADDWAIT4;
                end
	end

	PREADDREAD4: begin
		IPBCommand = 3'b010;
		next_WE = '0;
		next_CE = '0;
		next_ALE = '1;
		IPB_inputshift = '0;
		nextstate = ADDREAD4;
	end
	ADDREAD4: begin  //58
		next_WE = '1;
		IPBCommand = 3'b010;
		next_ALE = '1;
		next_CE = '0;
		IPB_inputshift = '1;
	 	nextstate = ADDREAD4NEXT;
	end
	ADDREAD4NEXT: begin  //59
		next_WE = '0;
		IPBCommand = 3'b000;
		next_CLE = '1;
		next_CE = '0;
		IPB_inputshift = '0;
		nextstate = ADDREAD4NEXT_2;
	end
	ADDREAD4NEXT_2: begin  //215
		next_WE = '0;
		IPBCommand = 3'b100;
		Command = 8'h30;
		next_CLE = '1;
		next_CE = '0;
		IPB_inputshift = '0;
		nextstate = COMMANDWRITE3;
	end
	COMMANDWRITE3: begin  //3
		Command = 8'h30;
		next_WE = '1;
		next_CLE = '1;
		next_CE = '0;
		IPBCommand = 3'b100;
		nextstate = AFTERCOMMANDWRITE3;
	end
	AFTERCOMMANDWRITE3: begin  //3
		Command = 8'h30;
		next_WE = '1;
		next_CLE = '1;
		next_CE = '0;
		IPBCommand = 3'b100;
		nextstate = COMMANDWRITE4;
	end
	COMMANDWRITE4: begin  //4
		Command = 8'h30;
		next_WE = '1;
		next_CLE = '1;
		next_CE = '0;
		IPBCommand = 3'b100;
		nextstate = RBWRITE1;
	end
	
	RBWRITE1: begin  //5
		IPBCommand = '0;
		next_WE = '1;
		next_CE = '0;
		next_RE = '1;
		if (RB == '0) begin
			nextstate = RBWRITE2;
		end
		else begin
			nextstate = RBWRITE1;
                end
	end
	
	RBWRITE2: begin //6
		OutputShift_nxt = 0;
		IPBCommand = '0;
		next_WE = '1;
		next_CE = '0;
                AddTimer_Ena = '0;
                next_FDataOE = 1;
		next_RolloverValue= APSMRollOverValue;
		if (RB == 1'b1) begin
			nextstate = COMMANDWRITE5;
		end
		else begin
			nextstate = RBWRITE2;
                end
	end
       COMMANDWRITE5: begin //7
                IPBCommand = 3'b100;
		next_RolloverValue= APSMRollOverValue;
                next_WE = '0;
                next_CLE = '1;
		next_CE = '0;
		AddTimer_Ena = '0;
                Command = 8'h31;
                nextstate = COMMANDWRITE6;
       end

       COMMANDWRITE6: begin   //8
                IPBCommand = 3'b100;
                next_WE = '1;
		next_CE = '0;
                next_CLE = '1;
		AddTimer_Ena = '0;
		next_RolloverValue= APSMRollOverValue;
                Command = 8'h31;
                if(RB == 1'b0) begin
                    nextstate = DRIDLE;
                end
                else begin
                    nextstate = COMMANDWRITE6;         
                end      
         end
    
        DRIDLE: begin //239
		next_CE = '0;
		next_RolloverValue= APSMRollOverValue;
                if(RB == 1'b1) begin
                    nextstate = ADDCOUNTERSETUP1;
                end
                else begin
                    nextstate = DRIDLE;
                end
        end
                      
       DATAREAD1A: begin   //80
                OPB_outputshift = '0;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		OutputShift_nxt = '0;
		Output_control = '0;
                next_RE = '0;
		next_FDataOE = '0;
		ACCEnable = '0;
               if(Full == 0) begin 
		nextstate = DATAREAD2A;
               end
               else begin
                nextstate = DATAREAD1A;
               end
	end
	
	DATAREAD2A: begin   //81
                OPB_outputshift = '0;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		OutputShift_nxt = '0;
		next_CE = '0;
                Output_control = '0;
		next_RE = '0;
		next_FDataOE = '0;
		ACCEnable = '1;
                nextstate = DATAREADWAIT1A;
        end
	
	DATAREADWAIT1A: begin  //82
                OPB_outputshift = '1;
		OutputShift_nxt = '0;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		next_RE = '1;
		ACCEnable = '0;
		next_FDataOE = '0;
		Status = 3'b001;
		if (ADDReached == 1'b1) begin
			nextstate = DATATERMINATED1;
		end
		else if (Full == 0) begin
                        nextstate = DATAREADWAIT2A;
                end
                else begin
			nextstate = DATAREADWAIT1A;
		end
	end
	
	DATAREADWAIT2A: begin  //83
                OPB_outputshift = '0;
		OutputShift_nxt = '1;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		next_RE = '1;
		next_FDataOE = '0;
		ACCEnable = '0;
		Status = 3'b001;
		if (ADDReached == 1'b1) begin
			nextstate = DATATERMINATED1;
		end
		else begin
			nextstate = DATAREAD1A;
		end
	end
 
       DATAREAD1B: begin   //84
                OPB_outputshift = '0;
		next_CE = '0;
		OutputShift_nxt = '0;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		Output_control = '0;
                next_RE = '0;
		ACCEnable = '0;
		next_FDataOE = '0;
	       if(Full == 0) begin 
		nextstate = DATAREAD2B;
               end
               else begin
                nextstate = DATAREAD1B;
               end
	end
	
	DATAREAD2B: begin   //85
                OPB_outputshift = '0;
		next_EndAddress = 12'd1023;
		OutputShift_nxt = '0;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
                Output_control = '0;
		next_RE = '0;
		next_FDataOE = '0;
		ACCEnable = '1;	        
                nextstate = DATAREADWAIT1B;
	end
	
	DATAREADWAIT1B: begin //86
                OPB_outputshift = '1;
		OutputShift_nxt = '0;
		next_RolloverValue = APSMRollOverValue;
		next_RE = '1;
		next_CE = '0;
		next_EndAddress = 12'd1023;
		ACCEnable = '0;
		next_FDataOE = '0;
		Status = 3'b001;
		if (ADDReached == 1'b1) begin
			nextstate = DATATERMINATED2;
		end
		else if (Full == 0) begin
                        nextstate = DATAREADWAIT2B;
                end
                else begin
			nextstate = DATAREADWAIT1B;
		end
	end
	
	DATAREADWAIT2B: begin  //87
                OPB_outputshift = '0;
		OutputShift_nxt = '1;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		next_RE = '1;
		next_FDataOE = '0;
		ACCEnable = '0;
		Status = 3'b001;
		if (ADDReached == 1'b1) begin
			nextstate = DATATERMINATED2;
		end
		else begin
			nextstate = DATAREAD1B;
		end
	end
 
       DATAREAD1C: begin   //88
                OPB_outputshift = '0;
		OutputShift_nxt = '0;
		Output_control = '0;
                next_EndAddress = 12'd66;
		next_RolloverValue= APSMRollOverValue;
                next_RE = '0;
		ACCEnable = '0;
		next_FDataOE = '0;
		next_CE = '0;
	      if(Full == 0) begin 
		nextstate = DATAREAD2C;
               end
               else begin
                nextstate = DATAREAD1C;
               end
	end
	
	DATAREAD2C: begin   //89
                OPB_outputshift = '0;
		next_EndAddress = 12'd66;
		OutputShift_nxt = '0;
		next_RolloverValue = APSMRollOverValue;
                Output_control = '0;
		next_RE = '0;
		next_CE = '0;
		next_FDataOE = '0;
		ACCEnable = '1;
                nextstate = DATAREADWAIT1C;
	end
	
	DATAREADWAIT1C: begin  //90
                OPB_outputshift = '1;
		OutputShift_nxt = '0;
		next_EndAddress = 12'd66;
		next_RolloverValue = APSMRollOverValue;
		next_RE = '1;
		next_FDataOE = '0;
		ACCEnable = '0;
		next_CE = '0;
		Status = 3'b001;
		if (ADDReached == 1'b1) begin
			nextstate = DATATERMINATED3;
		end
		else if (Full == 0) begin
                        nextstate = DATAREADWAIT2C;
                end
                else begin
			nextstate = DATAREADWAIT1C;
		end
	end
	
	DATAREADWAIT2C: begin //91
                OPB_outputshift = '0;
		next_EndAddress = 12'd66;
		OutputShift_nxt = '1;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		next_FDataOE = '0;
		next_RE = '1;
		ACCEnable = '0;
		Status = 3'b001;
		if (ADDReached == 1'b1) begin
			nextstate = DATATERMINATED3;
		end
		else begin
			nextstate = DATAREAD1C;
		end
	end
       
	ADDCOUNTERSETUP1: begin //240
                next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
                next_RE = '1;
		Status = 3'b001;
		if (Request == 4'b0001 || Request == 4'b1000) begin
	                nextstate = DATAREAD1A;
                        next_FDataOE = '0;
                end
		else begin
			nextstate = ADDCOUNTERSETUP1;
                end
        end
       
	ADDCOUNTERSETUP2: begin //241
                next_EndAddress = 12'd1023;
		Status = '0;
		next_CE = '0;
		next_RolloverValue= APSMRollOverValue;
                next_RE = '1;
                nextstate = DATAREAD1B;
        end
       
        ADDCOUNTERSETUP3: begin //242
                next_EndAddress = 12'd66;
		next_RolloverValue= APSMRollOverValue;
		next_CE = '0;
		Status = '0;
                next_RE = '1;
                nextstate = DATAREAD1C;
        end
              
	DATATERMINATED1: begin // 95
		OutputShift_nxt = '0;
		next_FDataOE = 0;
		next_EndAddress = 12'd1023;
		next_RolloverValue = APSMRollOverValue;
		next_RE = '1;
		ACCEnable = '0;
		next_CE = '0;
		Status = 3'b100;
		if(Full == 0) begin
			nextstate = DATATERMINATED1_NXT;
			OutputShift_nxt = '1;
		end
		else
			nextstate = DATATERMINATED1;
	end

	DATATERMINATED1_NXT: begin
		next_EndAddress = 12'd1023;
		if(Request == 4'b1000)
			nextstate = ADDCOUNTERSETUP2;
		else
			nextstate = DATATERMINATED1_NXT;   
	end
	
	DATATERMINATED2: begin //96
		OutputShift_nxt = '0;
		next_RolloverValue = APSMRollOverValue;
		next_RE = '1;
		ACCEnable = '0;
		next_CE = '0;
		next_FDataOE = 0;
		Status = 3'b100;
	        next_EndAddress = 12'd1023;
                if(Full == 0) begin
			nextstate = DATATERMINATED2_NXT;
			OutputShift_nxt = '1;
		end
		else
			nextstate = DATATERMINATED2;
	end

	DATATERMINATED2_NXT: begin
		next_EndAddress = 12'd66;
		if(Request == 4'b1000) begin 
			nextstate = ADDCOUNTERSETUP3;
                end
                else
			nextstate = DATATERMINATED2_NXT;
	end
	DATATERMINATED3: begin //97
		next_FDataOE = 0;
		OutputShift_nxt = '0;
		next_RE = '1;
		ACCEnable = '0;
		
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		Status = 3'b100;
		if(Full == 0) begin
			OutputShift_nxt = '1;
			nextstate = PRETERMINATEWAIT;
		end
		else
			nextstate = DATATERMINATED3;
        end
	PRETERMINATEWAIT: begin
		next_FDataOE = 0;
		OutputShift_nxt = '0;
		next_RE = '1;
		ACCEnable = '0;
		
		next_RolloverValue = APSMRollOverValue;
		next_CE = '0;
		Status = 3'b100;
		nextstate = TERMINATEWAIT1;
		AddTimer_Ena = '1;
	end

	TERMINATEWAIT1: begin  //98
		next_CE = '0;
		next_RE = '1;
                Status = 3'b000;
		OutputShift_nxt = '0;
		next_RolloverValue = APSMRollOverValue;
		AddTimer_Ena = '0;	
	        if(AddTimer_Rollover == 1) begin 
			nextstate = TERMINATEWAIT2;
                end
                else begin
                nextstate = RBWRITE2;	
                end
	end

	
	TERMINATEWAIT2: begin //99
		next_CE = '0;
		next_RE = '1;
		next_FDataOE = 1;
                //counterclear = '1;
		nextstate = RESET1;
                Done = '1;
		Status = '1;

	end
	
	ERRORCOMMAND: begin  //250
		IPBCommand = 3'b100;
		Command = 8'hFF;
		next_WE = '0;
		next_CE = '0;
		next_CLE = '1;
		nextstate = ERRORTERMINATED;
	end
	
	ERRORTERMINATED: begin  //251
		IPBCommand = 3'b100;
		Command = 8'hFF;
		next_WE = '1;
		next_CE = '0;
		next_CLE = '1;
		nextstate = IDLE;
    	end

//erase state regular operatnext_ion
        ECOMMANDWRITE1: begin   //10
                next_startvalue = 0;
                IPBCommand = 3'b100;
                Command = 8'h00;
		next_CE = '0;
                next_WE = 0;
                next_CLE = 1;
                APSEnable = 1;
                nextstate = PREECOMMANDWRITE2;
        end
	PREECOMMANDWRITE2: begin
		next_startvalue = 0;
                IPBCommand = 3'b100;
                Command = 8'h00;
		next_CE = '0;
                next_WE = 1;
                next_CLE = 1;
                APSEnable = 1;
                nextstate = ECOMMANDWRITE2;
	end

        ECOMMANDWRITE2: begin  //11
                IPBCommand = 3'b100;
		next_CE = '0;
                Command = 8'h00;
                APSEnable = 0;
             if(Request == 4'b0011) begin
                nextstate = EADDOUTPUT1;
                 next_CLE = 0;
                  next_WE = 0;
                 next_ALE = 1;
             end
             else if ((Request == 4'b0101) || (Request == 4'b0010)) begin
                nextstate = WRITEERASEAD1;
                 next_CLE = 0;
                 next_WE = 0;
                next_ALE = 1;
             end
             else begin
                nextstate = ECOMMANDWRITE2;
                 next_CLE = 1;
                 next_WE = 1;
             end
	end
        ECOMMANDWRITE3: begin //12
                IPBCommand = 3'b100;
		next_CE = '0;
                Command = 8'h30;
		clearOFCU = 1;
                next_WE = 0;
                next_CLE = 1;
                next_startvalue = '0;
                nextstate = ECOMMANDWRITE4;
        end
        ECOMMANDWRITE4: begin //13  
                IPBCommand = 3'b100;
		next_CE = '0;
                Command = 8'h30;
                next_WE = 1;
                next_CLE = 1;
                AddTimer_Clear = 1;
                nextstate = ERBWRITE1;
        end
        ERBWRITE1: begin //14
                AddTimer_Clear = 1;
                next_WE = 1;
		next_CE = '0;
                next_CLE = 0;
		next_startvalue = '0;
                if(RB == 0) begin
                	nextstate = ERBWRITE2;
                end 
                else begin
                	nextstate = ERBWRITE1;
                end
        end
        ERBWRITE2: begin //15
                next_WE = 1;
		next_CE = '0;
		next_RolloverValue= 7'd64;
                next_CLE = 0;
                if(RB == 1) begin
		next_startvalue = '0;
                nextstate = ECOMMANDWRITE5;
                end
                else begin
                nextstate = ERBWRITE2;
                end
        end
        ECOMMANDWRITE5: begin //16
                IPBCommand = 3'b100;
		next_RolloverValue= 7'd64;
		next_CE = '0;
                next_WE = 0;
		next_startvalue = '0;
                next_CLE = 1;
                AddTimer_Ena = 0;
                Command = 8'h31;
                nextstate = ECOMMANDWRITE6;
        end
        ECOMMANDWRITE6: begin //17
                IPBCommand = 3'b100;
		next_RolloverValue= 7'd64;
		next_CE = '0;
		next_startvalue = '0;
                next_WE = 1;
                next_CLE = 1;
                Command = 8'h31;
		if (RB == 0)
	                nextstate = EDRIDLE;
		else
			nextstate = ECOMMANDWRITE6;
        end
        ETERMINATEWAIT1: begin //104
               next_RE = 0;
               Status = 000;
               ACCEnable = 0;
		next_RolloverValue= 7'd64;
		next_startvalue = '0;
               AddTimer_Ena = 0;
               if(AddTimer_Rollover == 1) begin
                    nextstate = ETERMINATEWAIT2;
               end
               else begin
                    nextstate = ERBWRITE2;
               end
       end
       ETERMINATEWAIT2: begin //105
               next_CE = 0;
               next_RE = 1;
               //counterclear = 1;
               clearOFCU = 1;
               nextstate = ERESET1;
		next_startvalue = '0;
           end
      ERESET1: begin	//202
		next_CLE = '1;
		next_CE = '0;
		next_WE = '0;
		next_ALE = '0;
		Status = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		nextstate = ERESET2;
	end
	ERESET2: begin	//203
		next_CLE = '1;
		next_CE = '0;
		next_WE = '1;
		next_ALE = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		if (RB == 0)
			nextstate = ERESET3;
		else
			nextstate = ERESET2;
	end
	ERESET3: begin	//204
		next_WE = '1;
		next_CLE = '0;
		next_CE = '0;
		next_ALE = '0;
		IPBCommand = 3'b100;
		Command = 8'hFF;
		if (RB == 1) begin
			nextstate = ECOMMANDWRITE7;
                        next_WE = 0;
                        next_CLE = 1;
                        IPBCommand = 3'b100;
                        Command = 8'h60;
                end
		else begin
			nextstate = ERESET3;
                end
	end
      EERRORCOMMAND2: begin //205
               Status = 3'b011;
               IPBCommand = 3'b100;
               Command = 8'hFF;
               next_WE = 0;
               next_CLE = 1;
               nextstate = EERRORTERMINATED2;
               end
      EERRORTERMINATED2: begin //206
               IPBCommand = 3'b100;
               Command = 8'hFF;
               next_WE = 1;
               next_CLE = 1;
                 nextstate = IDLE;
               end
      EADDOUTPUT1: begin //60
               IPBCommand = 3'b100;
               next_ALE = 1;
               next_WE = 0;
               next_CLE = 0;
               Command = 8'h00;
               nextstate = EADDOUTPUT1NEXT;
               end
      EADDOUTPUT1NEXT: begin //61
               next_WE = 1;
               IPBCommand = 3'b100;
               Command = 8'h00;
               next_ALE = 1;
               next_CLE = 0;
               nextstate = EADDOUTPUT2;
               end
      EADDOUTPUT2: begin //62
               IPBCommand = 3'b100;
               Command = 8'h00;
               next_ALE = 1;
               next_CLE = 0;
               next_WE = 0; 
               nextstate = EADDOUTPUT2NEXT;
               end
      EADDOUTPUT2NEXT: begin //63
               next_WE = 1;
               next_CLE = 0;
               next_ALE = 1;
               IPBCommand = 3'b100;
               Command = 8'h00;
               nextstate = EADDWAIT3;
         end
       EADDWAIT3: begin //64
               next_WE = 1;
               IPB_inputshift = 0;
	       IPBCommand = 3'b010;
               next_ALE = 1;
               APSEnable = 1;
               if(Request == 4'b0111) begin
                    nextstate = EADDREAD3;
               end
               else begin
                    nextstate = EADDWAIT3;
               end
          end
       EADDREAD3: begin //65
               next_WE = 0;
               IPBCommand = 3'b010;
               IPB_inputshift = 1;
	       Command = Address;
               next_ALE = 1;
               nextstate = EADDREAD3NEXT;
        end
       EADDREAD3NEXT: begin //66
               next_WE = 1;
               IPBCommand = 3'b010;
               IPB_inputshift = 1;
               next_ALE = 1;
               nextstate = EADDWAIT4;
        end
      EADDWAIT4: begin //67
               next_WE = 1;
               IPB_inputshift= 0;
               next_ALE =1;
               IPBCommand = 3'b010;
             if(Request == 4'b0111) begin
		next_WE = 0;
               nextstate = EADDREAD4;
             end
             else begin 
               nextstate = EADDWAIT4;
             end   
        end
     EADDREAD4: begin//68
                next_WE = 1;
                IPBCommand = 3'b010;
                IPB_inputshift = 1;
               	next_ALE = 1;
               	nextstate = EADDREAD4NEXT;
            end
     EADDREAD4NEXT: begin //69
                next_WE = 1;
                IPBCommand = 3'b100;
                IPB_inputshift = 0;
                next_ALE = 0;
                next_CLE = 1;
                Command = 8'h30;
                nextstate = ECOMMANDWRITE3;
           end
     EDRIDLE: begin //200
                IPBCommand = 3'b010;
                next_ALE = 0;
                next_CLE = 0;
		next_RolloverValue= 7'd64;
                next_WE = 1;
		next_startvalue = '0;
		Output_control = 1;
                next_RE = 1;
                if(RB == 1) begin
                 nextstate = EADDCOUNTERSETUP1;
                end
                else begin
                 nextstate = EDRIDLE;
                end
              end
    EADDCOUNTERSETUP1: begin //201
                next_EndAddress = 12'd2112;
		Output_control = 1;
		next_RolloverValue= 7'd64;
		next_startvalue = '0;
                next_RE = 1;
                WriteOFC = 0;
                nextstate = EDATAREAD1;
             end
    EDATAREAD1: begin //100
                OPB_outputshift = 0;
                next_EndAddress = 12'd2112;
		next_RolloverValue= 7'd64;
		next_startvalue = '0;
		Output_control = 1;
		next_FDataOE=0;
                next_RE = 0;
                WriteOFC = 0;
                ACCEnable = 0;
                nextstate = EDATAREAD2;
             end
    EDATAREAD2: begin //101
                OPB_outputshift = 0;
		next_RolloverValue= 7'd64;
		next_FDataOE=0;
		next_startvalue = '0;
		Output_control = 1;
                next_RE = 0;
                ACCEnable = 1;
                WriteOFC = 0;
                nextstate = EDATAREADWAIT1;
             end
    EDATAREADWAIT1: begin //102
                OPB_outputshift = 1;
                next_RE = 1;
		next_RolloverValue= 7'd64;
		next_FDataOE=0;
		next_startvalue = '0;
		Output_control = 1;
                ACCEnable = 0;
                WriteOFC = 0;
              if(ADDReached == 1) begin
                nextstate = EDATATERMINATED1;
              end
              else begin
                nextstate = EDATAREADWAIT2;
              end
             end
    EDATAREADWAIT2: begin //103
                OPB_outputshift = 0;
		next_RolloverValue= 7'd64;
                next_RE = 1;
		next_startvalue = '0;
		Output_control = 1;
                ACCEnable = 0;
		next_FDataOE=0;
                WriteOFC = 0;
              if(ADDReached == 1) begin
                nextstate = EDATATERMINATED1;
              end
              else begin
          	nextstate = EDATAREAD1;
              end
           end
    EDATATERMINATED1: begin //45
               OPB_outputshift = 0;
	       AddTimer_Ena = 1;
		next_FDataOE=0;
		next_RolloverValue= 7'd64;
		next_startvalue = '0;
		Output_control = 1;
               next_RE = 1;
               WriteOFC = 0;
             nextstate = ETERMINATEWAIT1;
          end
    //erase data erase
    ECOMMANDWRITE7: begin   //18
               IPBCommand = 3'b100;
               next_WE = 1;
               next_CLE = 1;
               Command = 8'h60;
               clearOFCU = 1;
               nextstate = ECOMMANDWRITE8;
         end
    ECOMMANDWRITE8: begin   //19
               IPBCommand = 3'b100;
               next_WE = 0;
               next_CLE = 0;
               next_ALE = 1;
               Command = {block_address[1:0],6'b0};
               nextstate = EAD1;
              end
    ECOMMANDWRITE9: begin //20
              IPBCommand = 3'b100;
               next_WE = 1;
               next_CLE = 1;
               Command = 8'hD0;
               nextstate = ECOMMANDWRITE10;
             end
    ECOMMANDWRITE10: begin //21
              IPBCommand = 3'b100;
               next_WE = 1;
               next_CLE = 0;
               Command = 8'hD0;
               nextstate = ERBWRITE3;
              end
    ERBWRITE3: begin //22
               next_WE = 1;
               next_CLE = 0;
              if(RB == 0) begin
               nextstate = ERBWRITE4;
              end
              else begin
               nextstate = ERBWRITE3;
              end
             end
     ERBWRITE4: begin //23
               next_WE = 1;
               next_CLE = 0;
               if(RB == 1) begin
                nextstate = ECOMMANDWRITE11;
               end
               else begin
                nextstate = ERBWRITE4;
               end
          end
    ECOMMANDWRITE11: begin //24
               IPBCommand = 3'b100;
               next_WE = 0;
               next_CLE = 1;
               Command = 8'h70;
               nextstate = ECOMMANDWRITE12;
          end
    ECOMMANDWRITE12: begin //25
               IPBCommand = 3'b100;
               next_WE = 1;
               next_CLE = 1;
               Command = 8'h70;
               nextstate = EWAIT1;
           end
      EWAIT1: begin //26
              nextstate = EWAIT2;
          end
     EWAIT2: begin //27
              nextstate = EWAIT3;
          end
      EWAIT3: begin //28
	      next_FDataOE = 0;
              nextstate = ECHECK1;
              next_RE = 1;
          end
      ECHECK1: begin //29
	      next_FDataOE = 0;
              nextstate = ECHECK2; 
              next_RE = 0;
          end  
      ECHECK2: begin //30
	      next_FDataOE = 0;
              nextstate = ECHECK3;
              next_RE = 0;
              //counterclear = 1;
          end
      ECHECK3: begin //31
              next_RE = 1;
		next_RolloverValue= start_address;
             if(FDataOut[0] == 0) begin 
             nextstate = EWAIT4;
             end 
             else begin
             nextstate = EERRORCOMMAND2;
             end
           end
      EWAIT4: begin //32
              next_RE = 1;
              next_WE = 0;
              next_CLE = 1;
              IPBCommand = 3'b100;
              Command = 8'h80;
              nextstate = ECOMMANDWRITE13;
           end
       EAD1: begin //33
               IPBCommand = 3'b100;
               next_ALE = 1;
               next_WE = 1;
               next_CLE = 0;
               Command = {block_address[1:0],6'b0};
               nextstate = EAD1NEXT;
           end
       EAD1NEXT: begin //34
               IPBCommand = 3'b100;
               next_ALE = 1;
               next_WE = 0;
               Command = block_address[9:2];
               nextstate = EAD2;
           end
      EAD2: begin //35 
               IPBCommand = 3'b100;
               next_ALE = 1;
               next_WE = 1;
               next_CLE = 0;
               Command = block_address[9:2];
               nextstate = EAD2NEXT;
            end
      EAD2NEXT: begin //36
                next_WE = 0;
                IPBCommand = 3'b100;
                next_ALE = 0;
                Command = 8'hD0;
                 nextstate = ECOMMANDWRITE9;
                 next_CLE = 1;
             end
     //erase write back
      ECOMMANDWRITE13: begin //120
                IPBCommand = 3'b100;
                next_WE = 1;
                next_CLE = 1;
                Command = 8'h80;
                nextstate = ECOMMANDWRITE14;
           end
      ECOMMANDWRITE14: begin //121
                IPBCommand = 3'b100;
                next_WE = 0;
                next_ALE = 1;
                Command = 0;
               nextstate = EADWRITE1;
             end
       ECOMMANDWRITE15: begin //129
                IPBCommand = 3'b100;
                next_WE = 0;
                next_CLE = 1;
                Command = 8'h15;
                nextstate = ECOMMANDWRITE16;
             end
       ECOMMANDWRITE16: begin //130
                IPBCommand = 3'b100;
                next_WE = 1;
                next_CLE = 1;
                Command = 8'h15;
              nextstate = ERBWRITE5;
         end
       ERBWRITE5: begin //131
                next_WE = 1;
                next_CLE = 0;
            if(RB == 0) begin
              nextstate = ERBWRITE6;
            end
            else begin
              nextstate = ERBWRITE5;
            end
           end
       ERBWRITE6: begin //132
                 next_WE = 1;
                 next_CLE = 0;
            if(RB == 1) begin
             nextstate = ECOMMANDWRITE17;
            end
            else begin
             nextstate = ERBWRITE6;
            end
           end
       ECOMMANDWRITE17:begin //133
                 IPBCommand = 3'b100;
                 next_WE = 0;
                 next_CLE = 1;
                 Command = 8'h70;
               nextstate = ECOMMANDWRITE18;
             end
        ECOMMANDWRITE18: begin //134
                 IPBCommand = 3'b100;
                 next_WE = 1;
                 next_CLE = 1;
                 Command = 8'h70;
               nextstate = EWAIT5;
           end
          EMASKCHECK1: begin //142
                  next_WE = 1;
                  if(Request != 4'b0010 && Request != 4'b1111)
		//AHOpcode = 3'b100;
                   next_CLE = 0;
 		clearOFCU = 1;
                Command = 8'h80;
               if(AddTimer_Rollover == 1) begin
                nextstate = EMASKCHECK2;
                next_startvalue = end_address + 1;
               end
               else begin
                nextstate = ECOMMANDWRITE13;
                next_CLE = 1;
                next_WE = 0;
                IPBCommand = 3'b100;
                Command = 8'h80;
               end
             end
          EMASKCHECK2: begin //143
		   next_RolloverValue= 6'd64;
                 if(Request != 4'b0010 && Request != 4'b1111)
		AHOpcode = 3'b100;
		   if (end_address == 6'd63 && checkdone == 1)
		        nextstate = ERASEACKSUCCESS;
		   AddTimer_Clear = 1;
                   if(add_control == 1) begin
                   	nextstate = ERASEACKSUCCESS;
                   end
                   else begin
                   	nextstate = EMASKCHECK3;
		        next_startvalue = end_address + 1;
                   end 
             end

	  ERASEACKSUCCESS: begin //146
			Status = 3'b110;
			//Update ONCHIP SRAM
                        if(Request != 4'b0010 && Request != 4'b1111)
			AHOpcode = 3'b100;
			if(Request == 4'b0101 || Request == 4'b0010)
                        	nextstate = WDUMMY1;
			else if(checkdone == 1) begin
				nextstate = RESET1;
			end
	     end
          EMASKCHECK3: begin //144
			next_RolloverValue= 6'd64;
		   AddTimer_Clear = 1;
 		clearOFCU = 1;
                   Command = 8'h80;
		   next_startvalue = end_address + 1;
                   next_add_control = 1;
                   next_WE = 0;
                   next_CLE = 1;
                   Command = 8'h80;
                   IPBCommand = 3'b100;
                   nextstate = ECOMMANDWRITE13;
             end
          EADWRITE1: begin //37
                 IPBCommand = 3'b100;
                 next_ALE = 1;
                 next_WE = 1;
                 next_CLE = 0;
                 Command = '0;
               nextstate = EADWRITE1NEXT;
          end
          EADWRITE1NEXT: begin //38
                 IPBCommand = 3'b100;
                next_WE = 0;
                next_ALE = 1;
                Command = '0;
               nextstate = EADWRITE2;
             end
          EADWRITE2: begin //39
                 IPBCommand = 3'b100;
                next_WE = 1;
                next_ALE = 1;
                Command = '0;
                nextstate = EADWRITE2NEXT;
             end
          EADWRITE2NEXT: begin //40
                IPBCommand = 3'b100;
                next_WE = 0;
                next_ALE = 1;
                 Command = {block_address[1:0], CurrentAdd[5:0]};
                 nextstate = EADWRITE3;
              end
           EADWRITE3: begin //41
                next_WE = 1;
                next_ALE = 1;
                IPBCommand = 3'b100;
                Command = {block_address[1:0], CurrentAdd[5:0]};
                nextstate = EADWRITE3NEXT;
               end
           EADWRITE3NEXT: begin //42
                next_WE = 0;
                next_ALE = 1;
                IPBCommand = 3'b100;
                Command = block_address[9:2];
                nextstate = EADWRITE4;
               end
            EADWRITE4: begin //43
                next_WE = 1;
                next_ALE = 1;
                IPBCommand = 3'b100;
                Command = block_address[9:2];
                nextstate = EADWRITE4NEXT;
              end
            EADWRITE4NEXT: begin //44
                next_WE = 1;
                next_ALE = 1;
                IPBCommand = 3'b100;
                Command = block_address[9:2];
                    nextstate = EDATAPREPARE1;
              end
            EDATAPREPARE1: begin //122
                 IPBCommand = 3'b001;
                 next_EndAddress = 12'd1056;
                 IPB_inputshift = 0;
		 //next_RolloverValue= enderase;
		 //startvalue = starterase;
                 WriteOFC = 0;
                 next_WE = 1;
                 next_ALE = 0;
                 Command = CurrentAdd;
                nextstate = EDATAPREPARE2;
             end
           EDATAPREPARE2: begin //123
                 IPBCommand = 3'b001;
                 next_EndAddress = 12'd1056;
                 IPB_inputshift = 0;
		//AddTimer_Clear = 1;
                 WriteOFC = 1;
                 //AddTimer_Ena = 1;
                  next_WE = 1;
                 nextstate = EDATAPREPARE3;
                end
           EDATAPREPARE3: begin //124
                 IPBCommand = 3'b001;
                 IPB_inputshift = 0;
		 OFCUload = 1;
 		 WriteOFC = 1;
		//AddTimer_Clear = 0;
                 ACCEnable = 0;
                 AddTimer_Ena = 0;
                 next_WE =1;
                 nextstate = EDATAWRITE2;
               end
           EDATAWRITE2: begin //127
                 IPBCommand = 3'b001;
                 IPB_inputshift = 0;
                 next_WE = 0;
                 WriteOFC = 1;
                 ACCEnable = 0;
               	nextstate = EDATAWRITE3;
               end
        
            EDATAPREPARE5: begin //128
                IPBCommand = 3'b001;
                IPB_inputshift = 0;
                next_WE = 1;
                WriteOFC = 0;
                ACCEnable = 0;
              nextstate = ECOMMANDWRITE15;
              end
            //echeck state
           EWAIT5: begin //135
               nextstate = EWAIT6;
            end
           EWAIT6: begin //136
               nextstate = EWAIT7;
            end
           EWAIT7: begin //137
               nextstate = ECHECK4;
            end 
          ECHECK4: begin //138
               next_RE = 1;
               nextstate = ECHECK5;
            end
           ECHECK5: begin //139
               next_RE = 1;
               nextstate = ECHECK7;
            end
	ECHECK7: begin //145
		next_RE = 0;
		next_FDataOE = 0;
		nextstate = ECHECK6;
	end
         ECHECK6: begin //140
             next_RE = 1;
		next_FDataOE = 0;
            if(FDataOut[0] == 0) begin 
             nextstate = EWAIT8;
             end 
             else begin
             nextstate = EERRORCOMMAND2;
             end
            end
         EWAIT8: begin //141
	     AddTimer_Ena = '1;
               nextstate = EMASKCHECK1;
            end
	  EDATAWRITE3: begin //207
		IPBCommand = 3'b001;
		IPB_inputshift = 0;
		next_WE = 1;
		WriteOFC = 1;
		ACCEnable = 1;
		nextstate = EDATAWRITE4;
	     end
	  EDATAWRITE4: begin	//208
		IPBCommand = 3'b001;
		IPB_inputshift = 0;
		next_WE = 0;
		WriteOFC = 1;
		ACCEnable = 0;
		if (ADDReached)
			nextstate = EDATAPREPARE5;
		else
			nextstate = EDATAPREPARE3;
	   end
        //write operatnext_ion
         DIRTYCHECK1: begin  //150 
	   AHOpcode = 3'b010;
	   next_CE = 0; 
           next_startvalue = start_address;
           AddTimer_Clear = 1;
	   if(checkdone == 1) begin
	     nextstate = DIRTYCHECK2;
	   end
	   else begin
 	     nextstate = DIRTYCHECK1;
	   end
	  end
	 DIRTYCHECK2: begin //151
	  AHOpcode = 3'b010;
	  next_CE = 0;
           if(Dirty == 1) begin
             nextstate = ECOMMANDWRITE1;
             next_WE = 0;
             next_CLE = 1;
           end
           else begin
             nextstate = WDUMMY1;
           end
	  end
	 WRITEERASEAD1: begin //152
	  IPBCommand = 3'b100;
          Command = 0;
          next_ALE = 1;
          next_WE = 1;
          next_startvalue = 0;
          AddTimer_Clear = 1;
          nextstate = WRITEERASEAD1NEXT;
        end
        WRITEERASEAD1NEXT: begin //153
          next_WE = 0;
          IPBCommand = 3'b100;
          Command = '0;
          next_ALE = 1;
          AddTimer_Clear = 1;
          next_startvalue = 0;
          nextstate = WRITEERASEAD2;
       end 
        WRITEERASEAD2: begin //154
          next_WE = 1;
          next_CLE = 0;
          next_ALE = 1;
          Command = 0;
          IPBCommand = 3'b100;
          nextstate = WRITEERASEAD2NEXT;
       end
       WRITEERASEAD2NEXT: begin // 155
         next_WE = 0;
         IPBCommand = 3'b100;
         IPB_inputshift = 0;
         next_ALE = 1;
         Command = {block_address[1:0],6'b0};;
         nextstate = WRITEERASEAD3;         
      end
      WRITEERASEAD3: begin //156
          next_WE = 1;
          IPBCommand = 3'b100;
          next_ALE = 1;
          Command = {block_address[1:0],6'b0};
          nextstate = WRITEERASEAD3NEXT;
     end
     WRITEERASEAD3NEXT: begin //157
          next_WE= 0;
          IPBCommand = 3'b100;
          Command = block_address[9:2];
          next_ALE = 1;
          nextstate = WRITEERASEAD4;
    end
    WRITEERASEAD4: begin //158
          next_WE = 1;
          IPBCommand = 3'b100;
          Command = block_address[9:2];
          next_ALE = 1;
          nextstate = WRITEERASEAD4NEXT;
    end
    WRITEERASEAD4NEXT: begin //159
          next_WE = 0;
          next_ALE = 0;
          next_CLE = 1;
          IPBCommand = 3'b100;
          Command = 8'h30;
          nextstate = ECOMMANDWRITE3;
    end
    WRITEWAITAD1:begin //160
          APSEnable = 1;
          nextstate = WRITEWAITAD2;
    end
    WRITEWAITAD2:begin //161
          if(APSMstate == 4'd7) begin
            nextstate = DIRTYCHECK1;
          end
          else begin
            nextstate = WRITEWAITAD2;
          end
    end
    WCOMMANDWRITE1:begin //162
          IPBCommand = 3'b100;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          next_WE = 1;
          next_CLE = 1;
          Command = 8'h80;
          nextstate = WCOMMANDWRITE2;
    end
    WCOMMANDWRITE2: begin //163
          next_WE = 0;
          next_CLE = 0;
          next_ALE = 1;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          Command = 8'h00;
          IPBCommand = 3'b100;
          nextstate = WEADWRITE1;
    end
    WCOMMANDWRITE3: begin //164
          IPBCommand = 3'b100;
          next_WE = 1;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          next_CLE = 1;
          Command = 8'h15;
          nextstate = WCOMMANDWRITE4;
    end
    WCOMMANDWRITE4: begin //165
          IPBCommand = 3'b100;
          next_WE = 1;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          next_CLE = 1;
          Command = 8'h15;
          nextstate = WRBWRITE1;
   end 
   WRBWRITE1: begin //166
          next_WE = 1;
          next_CLE = 0;
          if(RB == 0) begin
            nextstate = WRBWRITE2;
          end
          else begin
            nextstate = WRBWRITE1;
          end
   end
   WRBWRITE2: begin //167
           next_WE = 1;
           next_CLE = 0;
             Command = 8'h70;
           IPBCommand = 3'b100;
          if(RB == 1) begin
            nextstate = WCOMMANDWRITE5;
            next_WE = 0;
            next_CLE = 1;
          end
          else begin     
            nextstate = WRBWRITE2;
          end
   end
    WCOMMANDWRITE5: begin //168
           IPBCommand = 3'b100;
             next_WE = 1;
             next_CLE = 1;
             Command = 8'h70;
            nextstate = WCOMMANDWRITE6;
    end
    WCOMMANDWRITE6: begin //169
           IPBCommand = 3'b100;
             next_WE = 1;
             next_CLE = 0;
             Command = 8'h70;
            nextstate = WWAIT5;
    end
   WRITETERMINATED: begin //170
          IPBCommand = 3'b100;
              next_WE = 1;
              next_CLE = 1;
              if(AddTimer_Rollover == 1) begin
                nextstate = DIRTYUPDATE;
              end
              else begin
                nextstate = WCOMMANDWRITE1;
                next_WE = 0;
                next_CLE = 1;
                IPBCommand = 3'b100;
                Command = 8'h80;
              end
   end
  WADDCOUNTERSETUP1: begin //171
          next_EndAddress = 12'd1023;
          next_WE = 1;
          next_startvalue = start_address;
          IPBCommand = 3'b011;
          next_RolloverValue= end_address + 1;
          if(Request == 4'b0101) begin 
              nextstate = WDATAREAD1A; 
              next_WE = 0;
          end
          else begin 
              nextstate = WADDCOUNTERSETUP1;
          end
  end
   WDATAREAD1A: begin //172
         next_EndAddress = 12'd1023;
          InputShift = 1;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
       //   if(Request == 4'b0101) begin 
          nextstate = WDATAREAD2A;
      //    end
        //  else begin
      //    nextstate = WDATAREAD1A;
       //   end
  end
   WDATAREAD2A: begin //173
          next_EndAddress = 12'd1023;
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 1;
          next_FDataOE = 1;
          IPB_inputshift = 1;
        //  if(Request == 4'b0101) begin
          nextstate = WDATAREADWAIT1A;
      //    end
     //     else begin
        //  nextstate = WDATAREAD2A;
    //      end
  end
   WDATAREADWAIT1A: begin //174
          next_EndAddress = 12'd1023;
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          if(ADDReached == 1) begin
          nextstate = WDATATERMINATED1;
          end
          else if (Request == 4'b0101) begin
          nextstate = WDATAREADDUMMY1;
          end
          else begin 
          nextstate = WDATAREADWAIT1A;
          end
  end
   WDATAREADDUMMY1: begin //220
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          nextstate = WDATAREADWAIT2A;
    end
   WDATAREADWAIT2A: begin //175
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          if(ADDReached == 1) begin
          nextstate = WDATATERMINATED1;
          end
          else begin 
          nextstate = WDATAREAD1A;
               next_WE = 0;
          end
  end
  WDATATERMINATED1: begin //176
         next_WE = 1;
         next_startvalue = start_address;
         next_RolloverValue= end_address + 1;
         Status = 3'b100;
         next_FDataOE = 1;
         IPBCommand = 3'b011;
      //   if(Request == 4'b0101) begin
         nextstate = W1;
       //  end
        // else begin
        // nextstate = WDATATERMINATED1;
        // end
  end

  W1: begin //214
         next_WE = 1;
         next_WE = 1;
         next_startvalue = start_address;
         next_RolloverValue= end_address + 1;
         Status = 3'b100;
         next_FDataOE = 1;
         IPBCommand = 3'b011;
         nextstate = WADDCOUNTERSETUP2;
         
  end
  WADDCOUNTERSETUP2: begin //177
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          next_EndAddress = 12'd1023;
          next_WE = 1;
          IPBCommand = 3'b011;
           if(Request == 4'b0101) begin
          nextstate = WDATAREAD1B;
           next_WE = 0; 
           end
           else begin
          nextstate = WADDCOUNTERSETUP2;
         end
  end
   WDATAREAD1B: begin //178
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 1;
          next_WE = 1;
          IPBCommand = 3'b011;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
       //   if(Request == 4'b0101) begin 
          nextstate = WDATAREAD2B;
      //    end
      ///    else begin
      //    nextstate = WDATAREAD1B;
      //    end
  end
   WDATAREAD2B: begin //179
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          ACCEnable = 1;
          next_FDataOE = 1;
          IPB_inputshift = 1;
       //   if(Request == 4'b0101) begin
          nextstate = WDATAREADWAIT1B;
    //      end
      //    else begin
        //  nextstate = WDATAREAD2B;
       //   end
  end
   WDATAREADWAIT1B: begin //180
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          if(ADDReached == 1) begin
          nextstate = WDATATERMINATED2;
          end
          else if (Request == 4'b0101) begin
          nextstate = WDATAREADDUMMY2;
          end
          else begin 
          nextstate = WDATAREADWAIT1B;
          end
  end
   WDATAREADDUMMY2: begin //221
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          nextstate = WDATAREADWAIT2B;
     end
   WDATAREADWAIT2B: begin //181
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          if(ADDReached == 1) begin
          nextstate = WDATATERMINATED2;
          end
      //    else if (Request == 4'b0101) begin
     //     nextstate = WDATAREAD1B;
      //    end
          else begin 
          nextstate = WDATAREAD1B;
          next_WE = 0;
          end
  end
  WDATATERMINATED2: begin //182
         next_WE = 1;
         next_startvalue = start_address;
         next_RolloverValue= end_address + 1;
         IPBCommand = 3'b011;
         Status = 3'b100;
         next_FDataOE = 1;
      //   if(Request == 4'b0101) begin
         nextstate = W2;
      //   end
       //  else begin
      //   nextstate = WDATATERMINATED2;
      //   end
  end
  W2: begin
         next_WE = 1;
         next_startvalue = start_address;
         next_RolloverValue= end_address + 1;
         IPBCommand = 3'b011;
         Status = 3'b100;
         next_FDataOE = 1;
         nextstate = WADDCOUNTERSETUP3;
   end
          
  WADDCOUNTERSETUP3: begin //183
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          next_EndAddress = 12'd66;
          IPBCommand = 3'b011;
          next_WE = 1;
          next_FDataOE = 1;
     if(Request == 4'b0101) begin
          nextstate = WDATAREAD1C; 
          next_WE = 0;
         end
        else begin
          nextstate = WADDCOUNTERSETUP3;
       end
  end
   WDATAREAD1C: begin //184
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 1;
          next_WE = 1;
          IPBCommand = 3'b011;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
       //   if(Request == 4'b0101) begin 
          nextstate = WDATAREAD2C;
        //  end
       //   else begin
       //   nextstate = WDATAREAD1C;
      //    end
  end
   WDATAREAD2C: begin //179
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          ACCEnable = 1;
          next_FDataOE = 1;
          IPB_inputshift = 1;
      //    if(Request == 4'b0101) begin
          nextstate = WDATAREADWAIT1C;
        //  end
       //   else begin
       //   nextstate = WDATAREAD2C;
     //     end
  end
   WDATAREADWAIT1C: begin //180
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          InputShift = 0;
          IPBCommand = 3'b011;
          next_WE = 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          if(ADDReached == 1) begin
          nextstate = WDATATERMINATED3;
          end
          else if (Request == 4'b0101) begin
          nextstate = WDATAREADDUMMY3;
          end
          else begin 
          nextstate = WDATAREADWAIT1C;
          end
  end
   WDATAREADDUMMY3: begin //222
          InputShift = 0;
          next_WE = 1;
          IPBCommand = 3'b011;
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          nextstate = WDATAREADWAIT2C;
     end
   WDATAREADWAIT2C: begin //187
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          IPBCommand = 3'b011;
          InputShift = 0;
          next_WE = 1;
          ACCEnable = 0;
          next_FDataOE = 1;
          IPB_inputshift = 0;
          if(ADDReached == 1) begin
          nextstate = WDATATERMINATED3;
          end
    //      else if (Request == 4'b0101) begin
    //      nextstate = WDATAREAD1C;
     //     end
          else begin 
          next_WE = 0;
          nextstate = WDATAREAD1C;
          end
  end
  WDATATERMINATED3: begin //182
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          IPBCommand = 3'b011;
         next_WE = 1;
         Status = 3'b100;
         next_FDataOE = 1;
         nextstate = W3;
  end

  W3: begin //216
          next_startvalue = start_address;
          next_RolloverValue= end_address + 1;
          IPBCommand = 3'b100;
          Command =8'h15;
         next_WE = 0;
         next_CLE = 1;
         Status = 3'b100;
         next_FDataOE = 1;
         nextstate = WCOMMANDWRITE3;
  end

           
  DIRTYUPDATE: begin //224
        AHOpcode = 3'b001;
        nextstate = DIRTYUPDATE1;
       end
  DIRTYUPDATE1: begin //189
        Status = 3'b010;
       if(checkdone == 1) begin
         nextstate = DIRTYUPDATE2;
       end
       else begin
         nextstate = DIRTYUPDATE1;
       end
  end  
  DIRTYUPDATE2: begin //190
        AHOpcode = 3'b000;
       nextstate = RESET1;
    end
          WEADWRITE1: begin //191
                 IPBCommand = 3'b100;
                 next_ALE = 1;
                 next_WE = 1;
                 next_CLE = 0;
                 Command = '0;
                 next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
               nextstate = WEADWRITE1NEXT;
          end
          WEADWRITE1NEXT: begin //192
                 IPBCommand = 3'b100;
                 next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
                next_WE = 0;
                next_ALE = 1;
                Command = '0;
               nextstate = WEADWRITE2;
             end
          WEADWRITE2: begin //193
                 IPBCommand = 3'b100;
                next_WE = 1;
                next_ALE = 1;
                 next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
                Command = '0;
                nextstate = WEADWRITE2NEXT;
             end
          WEADWRITE2NEXT: begin //193
                IPBCommand = 3'b100;
                next_WE = 0;
                next_ALE = 1;
                 Command =  {block_address[1:0], CurrentAdd[5:0]};
                 next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
                 nextstate = WEADWRITE3;
              end
           WEADWRITE3: begin //194
                next_WE = 1;
                next_ALE = 1;
                IPBCommand = 3'b100;
                 next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
                Command = {block_address[1:0], CurrentAdd[5:0]};
                nextstate = WEADWRITE3NEXT;
               end
           WEADWRITE3NEXT: begin //195
                next_WE = 0;
                next_ALE = 1;
                IPBCommand = 3'b100;
                next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
                Command = block_address[9:2];
                nextstate = WEADWRITE4;
               end
            WEADWRITE4: begin //196
                next_WE = 1;
                next_ALE = 1;
                IPBCommand = 3'b100;
                Command = block_address[9:2];
                next_startvalue = start_address;
                 next_RolloverValue= end_address + 1;
                nextstate = WEADWRITE4NEXT;
              end
            WEADWRITE4NEXT: begin //197
                next_ALE = 0;
                IPBCommand = 3'b100;
                Command = block_address[9:2];
                next_startvalue = start_address;
  
                 next_RolloverValue= end_address + 1;
                nextstate = WADDCOUNTERSETUP1;

              end
            WDUMMY1: begin //225
               Status = 3'b101;
               AddTimer_Clear = 1;
               next_startvalue = start_address;
               if(Request == 4'b1111)
               nextstate = WDUMMY2; 
               else
               nextstate = WDUMMY1; 
            end
            WDUMMY2: begin //226
               AddTimer_Clear = 1;
               next_startvalue = start_address;
               Status = 3'b101;
               if(Request == 4'b1111)
               nextstate = WDUMMY3; 
               else
               nextstate = WDUMMY2; 
            end
            WDUMMY3: begin //227
               AddTimer_Clear = 1;
               next_startvalue = start_address;
               IPBCommand = 3'b100;
               Status = 3'b101;
               Command = 8'h80;
               if(Request == 4'b1111) begin
               nextstate = WCOMMANDWRITE1; 
               next_WE = 0;
               next_CLE = 1;
               end
               else begin
               nextstate = WDUMMY3; 
               end
            end
   //Wcheck state
           WWAIT5: begin //228
               nextstate = WWAIT6;
               next_RolloverValue= end_address + 1;
            end
           WWAIT6: begin //229
               nextstate = WWAIT7;
   next_RolloverValue= end_address + 1;
            end
           WWAIT7: begin //230
               nextstate = WCHECK4;
   next_RolloverValue= end_address + 1;
            end 
          WCHECK4: begin 
               next_RE = 1;
               nextstate = WCHECK5;
   next_RolloverValue= end_address + 1;
            end
          WCHECK5: begin 
               next_RE = 1;
               nextstate = WCHECK7;
     next_RolloverValue= end_address + 1;
            end
	WCHECK7: begin 
		next_RE = 0;
		nextstate = WCHECK6;
  		next_RolloverValue= end_address + 1;
		next_FDataOE = 0;
	end
         WCHECK6: begin 
             next_RE = 1;
   next_RolloverValue= end_address + 1;
            //if(FDataOut[0] == 0) begin 
             nextstate = WWAIT8;
             //end 
             //else begin
             //nextstate = EERRORCOMMAND2;
             //end
            end
         WWAIT8: begin 
	     AddTimer_Ena = '1;
   		next_RolloverValue= end_address + 1;
               nextstate = WRITETERMINATED;
            end
	endcase
end

//assign modwait = modwait;

endmodule
