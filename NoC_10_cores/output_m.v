module OutPort (
dataOutE, 
dataOutW,
dataOutS,
dataOutN,
dataOutL,
Outr_L,Outr_N,Outr_E,Outr_S,Outr_W,
Outw_L,Outw_N,Outw_E,Outw_S,Outw_W,
DataFiFo,
rdreq,
clk,
empty,
reset
);

parameter position = 4'b0101; //ctntr X: 01 Y: 01
parameter DATA_WIDTH =37;

output [DATA_WIDTH-1:0]  dataOutE, dataOutW, dataOutS, dataOutN, dataOutL;
input empty;
input reset;
input clk;
output Outr_L,Outr_N,Outr_E,Outr_S,Outr_W;
input Outw_L,Outw_N,Outw_E,Outw_S,Outw_W;
input [DATA_WIDTH-1:0] DataFiFo;
output rdreq;
reg rdreq;
reg [DATA_WIDTH-1:0]  dataOutE, dataOutW, dataOutS, dataOutN, dataOutL;
reg [1:0] step;	/////////!!!!! can be 1 bit!!!
reg [2:0] port;
reg [4:0] Outr;
wire [4:0] Outw;

assign Outw = {Outw_L,Outw_N,Outw_E,Outw_S,Outw_W};
assign {Outr_L,Outr_N,Outr_E,Outr_S,Outr_W} = Outr;

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
        begin
			step<=0;
			port<=0;
			rdreq<=0;
			Outr<=0;
			
		end
    else
		begin
			case (step)
				0:  if (!empty)
							begin
								rdreq<=1;

								step=1;
							end
				1: 	begin
						rdreq<=0;
						if (Outw == Outr)
							begin
								Outr<=0;
								step=2;
							end
						//step=2;
					end
				2:  begin
																		//XY routing//
								if (DataFiFo [1:0] > position[1:0]) begin Outr <= 5'b00100; dataOutE<=DataFiFo; end //Inr ^ 4'b00100; //E
								else if (DataFiFo [1:0] < position[1:0]) begin Outr <= 5'b00001; dataOutW<=DataFiFo; end //W
								     else if (DataFiFo [3:2] > position[3:2]) begin Outr <= 5'b01000; dataOutN<=DataFiFo; end //N
								          else if (DataFiFo [3:2] < position[3:2]) begin Outr <= 5'b00010; dataOutS<=DataFiFo; end //S
											   else begin Outr<=5'b10000; dataOutL<=DataFiFo; end //L
								step=0;
					end

			endcase
		end
end				
endmodule