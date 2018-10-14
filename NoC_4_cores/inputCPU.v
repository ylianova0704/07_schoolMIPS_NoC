module inputCPU(
clk, reset,
dataOutL, // данные с маршрутизатора
Inw,
Outr,
dataFromRouterToCPU,
dataFromWhom,
dataGet //данные получены
);

parameter DATA_WIDTH=37;

input clk, reset;
output [DATA_WIDTH-1:0] dataOutL; 
input Inw, Outr;
output dataGet;
output [3:0] dataFromWhom;
input [DATA_WIDTH-1:0] dataFromRouterToCPU; // данные, которые попадут в ядро 

wire [DATA_WIDTH-1:0] dataFromRouterToCPU;
reg [DATA_WIDTH-1:0] dataInL;
reg [3:0] dataFromWhom;
wire Outr; 
wire Inw; 

assign Inw = Inw_L; 
assign Outr_L = Outr;


always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
		begin
			dataFromRouterToCPU <= 0;
			dataFromWhom <= 3'b0;
			//процессор не принимает данные, маршрутизатор не отправляет
			dataGet<=0;
		end
	else
		begin
			//извлекаем из пакета данные и адрес отправителя
			Outr<=1'b1;
			Inw<=1'b1;
			dataFromRouterToCPU <= dataOutL[36:5];
			dataFromWhom <= dataOutL[3:0];
			dataGet <= 1'b1;
		end	
end

endmodule	
