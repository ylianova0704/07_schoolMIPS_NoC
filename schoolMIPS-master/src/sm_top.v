//hardware top level module
module sm_top
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] clkDevide,
    input           clkEnable,
    output          clk,
    input   [ 4:0 ] regAddr,
    output  [31:0 ] regData,
	input   [ 7:0 ] dipValue,
	input   [ 3:0 ] ramAddr,
	output  [31:0]  ramData
);
    //metastability input filters
    wire    [ 3:0 ] devide;
    wire            enable;
    wire    [ 4:0 ] addr;

    sm_metafilter #(.SIZE(4)) f0(clkIn, clkDevide, devide);
    sm_metafilter #(.SIZE(1)) f1(clkIn, clkEnable, enable);
    sm_metafilter #(.SIZE(5)) f2(clkIn, regAddr,   addr  );

    //cores
    //clock devider
    sm_clk_divider sm_clk_divider
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .devide     ( devide    ),
        .enable     ( enable    ),
        .clkOut     ( clk       )
    );

    //instruction memory
    wire    [31:0]  imAddr;
    wire    [31:0]  imData;
    sm_rom reset_rom(imAddr, imData);

    sm_cpu sm_cpu
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr    ),
        .imData     ( imData    ),
		.dipValue   ( dipValue  ),
		.ramAddr    ( ramAddr   ),
		.ramDataB   ( ramData   )
    );
	
	sm_cpu sm_cpu_1
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr    ),
        .imData     ( imData    ),
		.dipValue   ( dipValue  ),
		.ramAddr    ( ramAddr   ),
		.ramDataB   ( ramData   )
    );
	
	sm_cpu sm_cpu_2
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr    ),
        .imData     ( imData    ),
		.dipValue   ( dipValue  ),
		.ramAddr    ( ramAddr   ),
		.ramDataB   ( ramData   )
    );
	
	sm_cpu sm_cpu_3
    (
        .clk        ( clk       ),
        .rst_n      ( rst_n     ),
        .regAddr    ( addr      ),
        .regData    ( regData   ),
        .imAddr     ( imAddr    ),
        .imData     ( imData    ),
		.dipValue   ( dipValue  ),
		.ramAddr    ( ramAddr   ),
		.ramDataB   ( ramData   )
    );
	
	router router
	(	
		.port       ( port      ),
		.in_1		( 

endmodule

module router // маршрутизатор
(
	input          port, // требуется определить порт для входа данных
	input  [127:0] in_1,
	input  [127:0] in_2,
	// input [127:0] in_3,
	output [127:0] out_1,
	output [127:0] out_2
	// output [127:0] out_3,
);
	wire port;
	reg active_port_1; // состояние порта: 0 - свободен, 1 - занят
	reg active_port_2;
	
	always @(posedge port) 
	begin
		active_port_1 = 1'b0;
		active_port_2 = 1'b0;
		if (port) // поступили данные
		begin
			if (active_port_1 == 1'b0)
				active_port_1 = 1'b1;
				in_1 <= out_data; // данные с процессоров
			else 
				if ((active_port_1 == 1'b1)&&(active_port_2 == 1'b0)) 
					active_port_2 = 1'b1;
					in_2 <= out_data;
				else
					// когда оба порта заняты
	end

	// OUT
	
endmodule
	
	
//metastability input filter module
module sm_metafilter
#(
    parameter SIZE = 1
)
(
    input                      clk,
    input      [ SIZE - 1 : 0] d,
    output reg [ SIZE - 1 : 0] q
);
    reg        [ SIZE - 1 : 0] data;

    always @ (posedge clk) begin
        data <= d;
        q    <= data;
    end

endmodule

//tunable clock devider
module sm_clk_divider
#(
    parameter shift = 16
)
(
    input           clkIn,
    input           rst_n,
    input   [ 3:0 ] devide,
    input           enable,
    output          clkOut
);
    wire [31:0] cntr;
    wire [31:0] cntrNext = cntr + 1;
    sm_register_we r_cntr(clkIn, rst_n, enable, cntrNext, cntr);

    assign clkOut = cntr[shift + devide];
endmodule
