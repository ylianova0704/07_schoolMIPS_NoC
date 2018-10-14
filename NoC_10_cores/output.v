module OutPort (
dataE, 
dataW,
dataS,
dataN,
dataL,
Inr,
Inw,
DataFiFo,
rdreq,
clk,
usedw,
reset
);

`define dlen 8 //packet width
parameter position = 4'b0101; //ctntr X: 01 Y: 01

output [31:0]  dataE, dataW, dataS, dataN, dataL;
input [6:0] usedw;
input reset;
input clk;
//inout InE, InW, InS, InN, InL; 
output [4:0] Inr;
input [4:0] Inw;
//inout [4:0] Inr;
//output WO;
input [31:0] DataFiFo;
output rdreq;
//wire [4:0] Inr;		//??
//reg WO; 
reg rdreq;
reg [31:0]  dataE, dataW, dataS, dataN, dataL;
reg [1:0] step;	/////////!!!!! can be 1 bit!!!
reg [2:0] port;
//reg [4:0] Inr;
reg [4:0] Inr;
//reg [4:0] position;

//assign  Inr = (WO) ? 5'bz : In;
always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
        begin
			step<=0;
			port<=0;
			rdreq<=0;
			Inr<=0;
			//position<=pos;
		end
    else
		begin
			case (step)
				
				0:  if (usedw != 0)
							begin
								rdreq<=1;
								//XY routing//
								if (DataFiFo [1:0] > position[1:0]) begin Inr <= 5'b00100; dataE<=DataFiFo; end //Inr ^ 4'b00100; //E
								else if (DataFiFo [1:0] < position[1:0]) begin Inr <= 5'b00001; dataW<=DataFiFo; end //W
								     else if (DataFiFo [3:2] > position[3:2]) begin Inr <= 5'b01000; dataN<=DataFiFo; end //N
								          else if (DataFiFo [3:2] < position[3:2]) begin Inr <= 5'b00010; dataS<=DataFiFo; end //S
											   else begin Inr<=5'b10000; dataL<=DataFiFo; end //L
//								if (DataFiFo [3:0] == position[3:0]) Inr<=4'b10000;
//								else if (DataFiFo [1:0] > position[1:0]) Inr <= 4'b00100;//Inr ^ 4'b00100; //E
//									 else if (DataFiFo [1:0] > position[1:0]) Inr <= 4'b00001; //W
//									      else if (DataFiFo [3:2] > position[3:2]) Inr <= 4'b01000; //N
//									           else if (DataFiFo [3:2] > position[3:2]) Inr <= 4'b00010; //S
								step=1;
							end
				1: 	begin
						rdreq<=0;
						if (Inw == Inr)
							begin
								Inr<=0;
								step=0;
							end
					end
//							case (Inw)
//								4'b10000: dataL<=DataFiFo;
//								4'b01000: dataN<=DataFiFo;
//								4'b00100: dataE<=DataFiFo;
//								4'b00010: dataS<=DataFiFo;
//								4'b00001: dataW<=DataFiFo;
//							endcase
			endcase
		end
end				
endmodule