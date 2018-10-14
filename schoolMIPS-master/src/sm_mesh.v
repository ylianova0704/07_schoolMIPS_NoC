/* Модуль ячейки сети. Представляет собой совокупность роутера и процессора.
 * В интерфейсе принимает линии связи с остальными ячейками.
 * Связь с процессором осуществляет сам.
 */

module sm_mesh
(
	clk, reset,

	/* линии данных, по которым роутеры передают друг другу сообщения */
	dataInE, dataInW, dataInS, dataInN,
	dataOutE, dataOutW, dataOutS, dataOutN,

	/* разрешающие сигналы, посредством которых роутеры получают друг от друга готовность читать / писать данныые */
	Inr_N, Inr_E, Inr_S, Inr_W,
	Inw_N, Inw_E, Inw_S, Inw_W,
	Outr_N,Outr_E,Outr_S,Outr_W,
	Outw_N,Outw_E,Outw_S,Outw_W
);
	parameter position = 'b0;
	
	/*** Объявления ***/

	// для связи с CPU

	wire [31:0] dataOut; // данные от процессора роутеру
	wire [31:0] dataIn; // данные для процессора от роутера
	wire [3:0]  dataOutDest; // точка назначения - приходит от процессора

	wire [36:0] dataForRouter; // данные, которые идут на роутер (зачем ещё 1 бит??..)
	wire [36:0] dataFromRouter; // данные, которые пришли из роутера

	wire dataForRouterReady; // процессор выставляет в 1, если данные есть
	wire routerReady; // сигнал от роутера, готов ли он данные получать. Эта линия передаётся в процессор
					  // по идее можно на неё забить.

	wire routerHasData; // сигнал о том, что роутер имеет данные
	wire dataFromRouterReady; // сигнал о том, что роутер готов отдать данные (слабо понимаю разницу с предыдущим)

	// Для связи с остальными роутерами

	input [36 : 0] dataInE, dataInW, dataInS, dataInN; // 4 addres, 1 endbit (что за бит??)
	output [36 : 0] dataOutE, dataOutW, dataOutS, dataOutN, dataOutL;
	input Inr_L, Inr_N, Inr_E, Inr_S, Inr_W;
	output Inw_L, Inw_N, Inw_E, Inw_S, Inw_W;
	output Outr_L,Outr_N,Outr_E,Outr_S,Outr_W;
	input Outw_L,Outw_N,Outw_E,Outw_S,Outw_W;
	input clk;
	input reset;

    /*** Код ***/

	assign dataForRouter = { dataOut, 1, dataOutDest}; // формируем пакет для роутера = данные + концевой бит + адрес назначения
	assign dataIn = { dataFromRouter[36:5] }; // извлекаем только данные

	sm_cpu mips_cpu
	(
		.clkIn (clk),
		.rst_n (rst),

		/* для связи с роутером */

		// Данные от CPU к роутеру
		.dataOut (dataOut),
		.dataOutDest (dataOutDest),
		.dataOutReady (dataForRouterReady),

		// Данные от роутера к CPU
		.dataIn (dataIn),
		.dataInReady (dataFromRouterReady),
	);

	NocSimpRout local_router #(position)
	(
		.clk (clk),
		.reset (rst),

		// соединения для связи с cpu
		.Inr_L (dataForRouterReady),
		.Inw_L (routerReady),
		.Outr_L (routerHasData),
		.Outw_L (dataFromRouterReady),

		.dataInL (dataForRouter),
		.dataOutL (dataFromRouter)

		// соединения для связи с соседними ячейками - приходят с уровня выше
		.dataInE (dataInE), .dataInW(dataInW), .dataInS(dataInS), .dataInN(dataInN),
		.dataOutE(dataOutE), .dataOutW(dataOutW), . dataOutS(dataOutS), .dataOutN(dataOutN),
		.Inr_N(Inr_N), .Inr_E(Inr_E), .Inr_S(Inr_S), .Inr_W(Inr_W),
		.Inw_N(Inw_N), .Inw_E(Inw_E), .Inw_S(Inw_S), .Inw_W(Inw_W),
		.Outr_N(Outr_N), .Outr_E(Outr_E), .Outr_S(Outr_S), .Outr_W(Outr_W),
		.Outw_N(Outw_N), .Outw_E(Outw_E), .Outw_S(Outw_S), .Outw_W(Outw_W)
	);

endmodule
