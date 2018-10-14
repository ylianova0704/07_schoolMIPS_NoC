module sm_input(
clk,
reset,
//dataInE, dataInN, dataInS, dataInW,
dataInL, // вход в локальный процессор
//Outr_N, Outr_E, Outr_S, Outr_W,
Outr_L,
//Outw_N,Outw_E,Outw_S,Outw_W,
Outw_L,
DataFiFo,
dataFromRouterToCPU,
dataReceived //данные получены
);

parameter position = 4'b0101; //ctntr X: 01 Y: 01
parameter DATA_WIDTH_EX =37;

input [DATA_WIDTH_EX-1:0] /* dataInE, dataInN, dataInS, dataInW,*/ dataInL; 
input reset;
input clk;
input Outr_L/*, Outr_N, Outr_E, Outr_S, Outr_W*/;
input Outw_L/*, Outw_N, Outw_E, Outw_S, Outw_W*/;
input [DATA_WIDTH_EX-1:0] DataFiFo; // данные с маршрутизатора

output [31:0] dataFromRouterToCPU; //на выходе inputa сетевого интерфейса процессора данные попадают в само ядро
output dataReceived;

reg [31:0] dataFromRouterToCPU;
reg [DATA_WIDTH_EX-1:0] /*dataInE, dataInW, dataInS, dataInN,*/ dataInL;
//reg [1:0] step;	/////////!!!!! can be 1 bit!!!
//reg [2:0] port;
reg [4:0] Outr; // маршрутизатор хочет отправить
wire [4:0] Outw; // процессор готов принимать

assign Outw = Outw_L; //{Outw_L,Outw_N,Outw_E,Outw_S,Outw_W};
assign /*{Outr_L,Outr_N,Outr_E,Outr_S,Outr_W}*/ Outr_L = Outr;

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
		begin
			Outr<=0;// маршрутизатор не отправляет данные
			Outw<=0;// процессор не принимает данные
		end
	else
		begin
			Outr<=1;
			Outw<=1;
			dataFromRouterToCPU <= DataFiFo [36:5];
			dataReceived = 1'b1;
		end	
end
	
endmodule	
		
	
		

/*
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
endmodule*/