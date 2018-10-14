module outputCPU(
clk, reset,
dataFromCPUToRouter,
dataToWhom,
dataSend, //отправить данные
dataInL, // данные, идущие на маршрутизатор
Inr,
Outw
);

parameter DATA_WIDTH=37;
//parameter DATA_CPU=3

input clk, reset;
input [31:0] dataFromCPUToRouter; 
input [3:0] dataToWhom;
input dataSend;
output [DATA_WIDTH-1:0] dataInL; 
output Inr, Outw;

wire [31:0] dataFromCPUToRouter;
reg [DATA_WIDTH-1:0] dataInL;
wire [3:0] dataToWhom;
wire Outw_L; // маршрутизатор хочет отправить
wire Inr_L; // процессор готов принимать

assign Inr_L = Inr; 
assign Outw = Outw_L;

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
		begin
			//маршрутизатор не принимает данные, процессор не отправляет
			Outw_L=1'b0;
			Inr_L=1'b0;
			dataSend=1'b0;
		end
	else
		begin
			//формируем пакет данных
			//{данные, флаг конца данных, адрес назначения}
			Outw_L=1'b1;
			Inr_L=1'b1;
			dataInL={dataFromCPUToRuter, 1'b1, dataToWhom};
			dataSend = 1'b1;
		end	
end

endmodule	
