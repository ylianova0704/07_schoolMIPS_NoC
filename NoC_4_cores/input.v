//rev 1

module InPort (
dataE, 
dataW,
dataS,
dataN,
dataL,
Inr,
Inw,
DataFiFo,
wrreq,
clk,
usedw,
reset
);

input [31:0]  dataE, dataW, dataS, dataN, dataL;
input [6:0] usedw;
input reset;
input clk;
input [4:0] Inr;
output [4:0] Inw;
output [31:0] DataFiFo;
output wrreq;
wire [4:0] Inr;		//??
reg wrreq;
reg [31:0] DataFiFo;
reg [1:0] step;	/////////!!!!! can be 1 bit!!!
reg [2:0] port;
reg [4:0] Inw;

//assign  Inr = (WO) ? 5'bz : In;
always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
        begin
			step<=0;
			port<=0;
			wrreq<=0;
			Inw<=0;
		end
    else
		begin
			case (step)
				
				0:  begin
						if ((usedw != 7'b1111111)&&(Inr > 0)) 
							begin
								if ((DataFiFo[4] == 1'b1) || (Inr[port] != 1'b1))
									begin
										if (port==4) port = 0;
										else port=port+1;
									end
								if (Inr[port] == 1'b1) 
									begin
										Inw<=(1'b1 << port);
										case (port)
											0: DataFiFo<=dataW;
											1: DataFiFo<=dataS;
											2: DataFiFo<=dataE;
											3: DataFiFo<=dataN;
											4: DataFiFo<=dataL;	
										endcase
										wrreq<=1'b1;
										step=1;
									end
							end							
					end	
				1:  begin
						wrreq<=1'b0;
						if (Inr[port] == 1'b0) 
							begin 
								Inw<=0;
								step=0; 									
							end
					end
			endcase
		end
	
end


endmodule
/*
module InPort (
dataE, 
dataW,
dataS,
dataN,
dataL,
/*InE,
InW,
InS,
InN,
InL,
*/
/*Inr,
//Inw,
WO,
DataFiFo,
wrreq,
clk,
usedw,
reset
);

`define dlen 8 //packet width

input [31:0]  dataE, dataW, dataS, dataN, dataL;
input [6:0] usedw;
input reset;
input clk;
*/
//inout InE, InW, InS, InN, InL; 
/*input [4:0] Inr;
output [4:0] Inw;*/
/*
inout [4:0] Inr;
output WO;
output [31:0] DataFiFo;
output wrreq;
wire [4:0] Inr;		//??
reg WO; 
reg wrreq;
reg [31:0] DataFiFo;
reg [2:0] step;
reg [2:0] port;
//reg [4:0] Inr;
reg [4:0] In;

//assign In=Inr;

assign  Inr = (WO) ? 5'bz : In;
always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
        begin
			step<=0;
			port<=0;
			wrreq<=0;
		end
    else
		begin
			case (step)
				0: 	begin
						WO<=1'b0;
						In<= 4'b0;
						step=1;
					end
				1: 	begin
						WO<=1'b1;
						In <= Inr;
						step=2;
					end
				2:  begin
						if ((usedw < 7'b1111001)&&(In > 0)) 
							begin
								if (In[port] == 1'b1) 
									begin
										//In<=5'b11111; //???
										//In[port]<=1'b0;
										WO<=1'b0;
										In<=~(1'b1 << port);
										//WO<=1'b1;
										step=3;
									end
								else 
									if (port==4) port = 0;
									else port=port+1;
										
							end							
					end	
				3:  begin
						WO<=1'b1;
						In <= Inr;//!
						if (In[port] == 1'b1) 
							begin
								case (port)
									0: DataFiFo<=dataE;
									1: DataFiFo<=dataW;
									2: DataFiFo<=dataS;
									3: DataFiFo<=dataN;
									4: DataFiFo<=dataL;	
								endcase
								wrreq<=1'b1;
								step=4;
							end					
					end
				4:  begin
						wrreq<=1'b0;
						if (DataFiFo[4] == 1'b1) step = 0;
						else 
							begin
								WO<=1'b0;
								In<=~(1'b1 << port);
								step = 3;
							end
					end
			endcase
		end
	
end


endmodule*/