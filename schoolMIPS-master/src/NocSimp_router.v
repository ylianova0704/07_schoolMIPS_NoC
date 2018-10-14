module NocSimpRout (
dataInE, 
dataInW,
dataInS,
dataInN,
dataInL,
dataOutE, 
dataOutW,
dataOutS,
dataOutN,
dataOutL,
Inr_L,Inr_N,Inr_E,Inr_S,Inr_W,
Inw_L,Inw_N,Inw_E,Inw_S,Inw_W,
Outr_L,Outr_N,Outr_E,Outr_S,Outr_W,
Outw_L,Outw_N,Outw_E,Outw_S,Outw_W,
clk,
reset
);

parameter position = 4'b0101; //ctntr X: 01 Y: 01
parameter DATA_WIDTH=37;
parameter FIFO_DEPTH=4; //2^5=32 - 32 data flits in FIFO 
//parameter MAX_COUNT = 2**FIFO_DEPTH;

input [DATA_WIDTH-1 : 0] dataInE, dataInW, dataInS, dataInN, dataInL; // 4 addres, 1 endbit
output [DATA_WIDTH-1 : 0] dataOutE, dataOutW, dataOutS, dataOutN, dataOutL;
input Inr_L, Inr_N, Inr_E, Inr_S, Inr_W;
output Inw_L, Inw_N, Inw_E, Inw_S, Inw_W;
output Outr_L,Outr_N,Outr_E,Outr_S,Outr_W;
input Outw_L,Outw_N,Outw_E,Outw_S,Outw_W;
input clk;
input reset;

//reg [DATA_WIDTH+4:0] dataOutE, dataOutW, dataOutS, dataOutN, dataOutL;
//reg Inw_L, Inw_N, Inw_E, Inw_S, Inw_W;
reg [DATA_WIDTH-1 : 0] mem [2**FIFO_DEPTH-1:0];
reg   [FIFO_DEPTH-1 : 0]   rd_ptr;
reg   [FIFO_DEPTH-1 : 0]   wr_ptr;

reg [4:0] Inw;
wire [4:0] Inr;
reg [4:0] Outr;
wire [4:0] Outw;

reg [DATA_WIDTH-1:0] dataOutE, dataOutW, dataOutS, dataOutN, dataOutL;

reg stepr, stepw;
reg [2:0] port;


assign Inr = {Inr_L,Inr_N,Inr_E,Inr_S,Inr_W};
assign {Inw_L,Inw_N,Inw_E,Inw_S,Inw_W} = Inw;
assign Outw = {Outw_L,Outw_N,Outw_E,Outw_S,Outw_W};
assign {Outr_L,Outr_N,Outr_E,Outr_S,Outr_W} = Outr;

always @(posedge clk or posedge reset)
	if (reset) 
		begin 
			wr_ptr <= 'h0;
			rd_ptr <= 'h0;
			stepr<=0;
			stepw<=0;
			port<=0;
			Inw<=0;
			Outr<=0;
		end
	else
		begin
			case (stepr)
				0:  begin
						if ((rd_ptr != (wr_ptr+1))&&(Inr > 0)) 
							begin
								if ((mem[wr_ptr][4] == 1'b1) || (Inr[port] != 1'b1))
									begin
										if (port==4) port <= 0;
										else port<=port+1;
									end
								if (Inr[port] == 1'b1) 
									begin
										Inw<=(1'b1 << port);
										case (port)
											0: mem[wr_ptr]<=dataInW;
											1: mem[wr_ptr]<=dataInS;
											2: mem[wr_ptr]<=dataInE;
											3: mem[wr_ptr]<=dataInN;
											4: mem[wr_ptr]<=dataInL;	
										endcase
										stepr=1;
									end
							end							
					end	
				1:  begin
						if (Inr[port] == 1'b0) 
							begin 
								wr_ptr<=wr_ptr+1;
								Inw<=0;
								stepr<=0; 									
							end
					end
			endcase
			
			case (stepw)
				0:  if (rd_ptr != wr_ptr)
							begin
								//XY routing//
								if (mem[rd_ptr] [1:0] > position[1:0]) begin Outr <= 5'b00100; dataOutE=mem[rd_ptr]; end //Inr ^ 4'b00100; //E
								else if (mem[rd_ptr] [1:0] < position[1:0]) begin Outr <= 5'b00001; dataOutW=mem[rd_ptr]; end //W
								     else if (mem[rd_ptr] [3:2] > position[3:2]) begin Outr <= 5'b01000; dataOutN=mem[rd_ptr]; end //N
								          else if (mem[rd_ptr] [3:2] < position[3:2]) begin Outr <= 5'b00010; dataOutS=mem[rd_ptr]; end //S
											   else begin Outr<=5'b10000; dataOutL<=mem[rd_ptr]; end //L
								stepw=1;
							end
				1: 	begin
						if (Outw == Outr)
							begin
								rd_ptr<=rd_ptr+1;
								Outr<=0;
								stepw<=0;
							end
					end
			endcase
		end


endmodule
