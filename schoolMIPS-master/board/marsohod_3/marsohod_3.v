module marsohod_3(
      input       CLK100MHZ,
      input       KEY0,
      input       KEY1,
      output      [7:0]  LED

);

    // wires & inputs
    wire          clk;
    wire          clkIn     =  CLK100MHZ;
    wire          rst_n     =  KEY0;
    wire          clkEnable =  ~KEY1;
	 wire [ 31:0 ] regData;

    //cores
    sm_top sm_top
    (
        .clkIn      ( clkIn     ),
        .rst_n      ( rst_n     ),
        .clkDevide  ( 4'b1000   ),
        .clkEnable  ( clkEnable ),
        .clk        ( clk       ),
        .regAddr    ( 4'b0010   ),
        .regData    ( regData   )
    );

    //outputs
    assign LED[0]   = clk;
    assign LED[7:1] = regData[6:0];

endmodule


/*module marsohod_3
(
input [2:0] KEY,
input CLK100MHZ,
output reg [3:0] LED,
input [19:0] IO
);
always @(posedge CLK100MHZ)
begin
	LED[0] <= CLK100MHZ;
	LED[1] <= IO[19];
	LED[2] <= IO[17];
	LED[3] <= IO[15];
end
endmodule


module marsohod_3
(
input [2:0] KEY,
input CLK100MHZ,
output reg [3:0] LED,
input [19:0] IO
);
wire ab, abc // synthesis keep;
assign ab=IO[19]&IO[17];
assign abc=ab&IO[15];
always @ (posedge CLK100MHZ)
begin
LED[1]<=abc;
end
endmodule
*/

