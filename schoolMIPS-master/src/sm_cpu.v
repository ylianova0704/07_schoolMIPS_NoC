/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 *                   Alexander Romanov 
 */ 

`include "sm_cpu.vh"

module sm_cpu
(
    input           clk,        // clock
    input           rst_n,      // reset
    input   [ 4:0]  regAddr,    // debug access reg address
    output  [31:0]  regData,    // debug access reg data
    output  [31:0]  imAddr,     // instruction memory address
    input   [31:0]  imData,     // instruction memory data
	input   [7:0]   dipValue,
	input   [3:0]   ramAddr,
	output  [31:0]  ramDataB,
	
	input 	[31:0] 	dataFromRouterToCPU,
	input 		 	dataReceived,
);
    //control wires
    wire        pcSrc;
    wire        regDst;
    wire        regWrite;
    wire        aluSrc;
    wire        aluZero;
	wire        pcJ;
	wire        isDip;
    wire [ 4:0] aluControl;

    //program counter
    wire [31:0] pc;
    wire [31:0] pcBranch;
    wire [31:0] pcNext  = pc + 1;
	wire [31:0] pcJump;
    wire [31:0] pc_old  = ~pcSrc ? pcNext : pcBranch; //multiplexor for PC_new
    wire [31:0] pc_new = pcJ ? pcJump : pc_old; //multiplexor for PC_Jump
	sm_register r_pc(clk ,rst_n, pc_new, pc);

    //program memory access
    assign imAddr = pc;
    wire [31:0] instr = imData;
	
	//Jump
	assign pcJump = {pcNext[31:26],instr[25:0]};

    //debug register access
    wire [31:0] rd0;
    assign regData = (regAddr != 0) ? rd0 : pc;
	
	//RAM
	wire [31:0] ramData;
	wire ramRead;
	wire ramWriteE;
	
	wire [31:0] result;	

    //register file
    wire [ 4:0] a3  = regDst ? instr[15:11] : instr[20:16];
    wire [31:0] rd1;
    wire [31:0] rd2;
    //wire [31:0] wd3; // was before ramA
	wire [31:0] wd3 = ramRead ? ramData : result;

    sm_register_file rf
    (
        .clk        ( clk          ),
        .a0         ( regAddr      ),
        .a1         ( instr[25:21] ),
        .a2         ( instr[20:16] ),
        .a3         ( a3           ),
        .rd0        ( rd0          ),
        .rd1        ( rd1          ),
        .rd2        ( rd2          ),
        .wd3        ( wd3          ),
        .we3        ( regWrite     )
    );

    //sign extension
    wire [31:0] signImm = { {16 { instr[15] }}, instr[15:0] };
    assign pcBranch = pcNext + signImm;

    //alu
	//if aluSrc = 1, then srcB = signImm;
	//if aluSrc = 0, then srcB = rd2;
	//signImm - rashirenie s soxraneniem znaka;
    // wire [31:0] srcB = aluSrc ? signImm : rd2; // norm
	wire [31:0] srcB = isDip ? dipValue : (aluSrc ? signImm : rd2); //for dip

    sm_alu alu
    (
        .srcA       ( rd1          ), //srcA budet prisvoeno zhachenie rd1;
        .srcB       ( srcB         ),
        .oper       ( aluControl   ),
        .shift      ( instr[10:6 ] ),
        .zero       ( aluZero      ),
     // .result     ( wd3          ), //was before ram
		.result     ( result       ),
		.pb         ( pb           )
    );

    //control
    sm_control sm_control
    (
        .cmdOper    ( instr[31:26] ),
        .cmdFunk    ( instr[ 5:0 ] ),
        .aluZero    ( aluZero      ),
        .pcSrc      ( pcSrc        ),
		.pcJ		( pcJ		   ),
        .regDst     ( regDst       ), 
        .regWrite   ( regWrite     ), 
        .aluSrc     ( aluSrc       ),
        .aluControl ( aluControl   ),
		.isDip      ( isDip        ),
		.ramRead    ( ramRead      ),
		.ramWriteE  ( ramWriteE    )
    );

	// RAM
	sm_ram_memory sm_ram_memory
	(
		.data_a     ( rd2          ),
		.data_b     ( 'b0          ),
		.wd_a       ( result >> 2  ),
		.wd_b       ( ramAddr      ),
		.we_a       ( ramWriteE    ),
		.we_b       ( 'b0          ),
		.clk        ( clk          ),
		.rd_a       ( ramData      ),
		.rd_b       ( ramDataB     )
	);
	
endmodule

module sm_control
(
    input      [5:0] cmdOper,
    input      [5:0] cmdFunk,
    input            aluZero,
    output           pcSrc,
	output			 pcJ,
    output reg       regDst, 
    output reg       regWrite, 
    output reg       aluSrc,
    output reg [4:0] aluControl,
	output           isDip,
	output reg       ramRead,
	output reg       ramWriteE
);
    reg              branch;
    reg              condZero;
	reg              _isDip;
	reg 		     _pcJ;
	
	assign isDip = _isDip;
	assign pcJ = _pcJ;
    assign pcSrc = branch & (aluZero == condZero); // if (...) = 1 and branch = 1, pcsrc = 1; LOGIC AND

    always @ (*) begin
        branch      = 1'b0;
        condZero    = 1'b0;
        regDst      = 1'b0; //if regDst = 0, to result go [20:16]; if regDst = 1, to result go [15:11]
        regWrite    = 1'b0; //write to register
        aluSrc      = 1'b0;
		_isDip      = 1'b0;
		_pcJ        = 1'b0;
		ramRead     = 'b0;
		ramWriteE   = 'b0;
        aluControl  = `ALU_ADD;

        casez( {cmdOper,cmdFunk} )
            default               : ;

            { `C_SPEC,  `F_ADDU } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `C_SPEC,  `F_OR   } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `C_SPEC,  `F_SRL  } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `C_SPEC,  `F_SLTU } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `C_SPEC,  `F_SUBU } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SUBU; end
			{ `C_SPEC2, `F_SRL  } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_MUL;  end
			{ `C_SPEC,  `F_SLLV } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_SLLV; end
			{ `C_SPEC,  `F_XOR  } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_XOR;  end
			{ `C_SPEC,  `F_AND  } : begin regDst = 1'b1; regWrite = 1'b1; aluControl = `ALU_AND;  end

            { `C_ADDIU, `F_ANY  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD;  end
            { `C_LUI,   `F_ANY  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_LUI;  end
			{ `C_SLTIU, `F_ANY  } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_SLTIU; end

            { `C_BEQ,   `F_ANY  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUBU; end
            { `C_BNE,   `F_ANY  } : begin branch = 1'b1; aluControl = `ALU_SUBU; end
			{ `C_J,     `F_ANY  } : begin _pcJ = 1'b1; end
			
			{ `C_DIP,	`F_ANY	} : begin $write("\nDIP\n"); _isDip = 1'b1; regWrite = 1'b1; aluControl = `ALU_DIP; end
			
			{ `C_SW,    `F_ANY  } : begin ramWriteE = 'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
			{ `C_LW,    `F_ANY  } : begin ramRead = 'b1; regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
        endcase
    end
endmodule


module sm_alu
(
    input  [31:0] srcA,
    input  [31:0] srcB,
    input  [ 4:0] oper,
    input  [ 4:0] shift,
	output reg 	  pb,
    output        zero,
    output reg [31:0] result
);
    always @ (*) begin
        case (oper)
            default   : result = srcA + srcB;
            `ALU_ADD  : result = srcA + srcB;
            `ALU_OR   : result = srcA | srcB;
            `ALU_LUI  : result = (srcB << 16);
            `ALU_SRL  : result = srcB >> shift;
            `ALU_SLTU : result = (srcA < srcB) ? 1 : 0;
            `ALU_SUBU : result = srcA - srcB;
			`ALU_MUL  : result = srcA * srcB;
			`ALU_SLTIU: result = (srcA < srcB) ? 1 : 0;
			`ALU_SLLV : result = srcB << (srcA & 'b11111);
			`ALU_XOR  : result = srcA ^ srcB;
			`ALU_AND  : result = srcA & srcB;
			`ALU_DIP  : result = srcB;
			//`ALU_DIP  : begin pb = srcB[0]^srcB[1]^srcB[2]^srcB[3]^srcB[4]^srcB[5]^srcB[6]^srcB[7]; result = {{24{pb}},srcB[7:0]}; end
        endcase
    end

    assign zero   = (result == 0); // if result = 0, zero = 1
endmodule

module sm_register_file
(
    input         clk,
    input  [ 4:0] a0,
    input  [ 4:0] a1,
    input  [ 4:0] a2,
    input  [ 4:0] a3,
    output [31:0] rd0,
    output [31:0] rd1,
    output [31:0] rd2,
    input  [31:0] wd3,
    input         we3
);
    reg [31:0] rf [31:0];

    assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
    assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
    assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

    always @ (posedge clk)
        if(we3) rf [a3] <= wd3;
endmodule

//RAM
module sm_ram_memory
#(parameter DATA_WIDTH=32, parameter WD_WIDTH=4)
(
	input [(DATA_WIDTH-1):0] data_a, data_b, // [31:0]
	input [(WD_WIDTH-1):0] wd_a, wd_b, // [31:0]
	
	input we_a, we_b, clk,
	
	output [(DATA_WIDTH-1):0] rd_a, rd_b // [31:0]
);
	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**WD_WIDTH-1:0]; // [31:0]  [31:0]

	initial begin
		$readmemh ("ram.hex", ram);
	end
	
	assign rd_a = ram[wd_a];
	assign rd_b = ram[wd_b];
	
	// Port A 
	always @ (posedge clk)
	begin
		if (we_a) 
			ram[wd_a] <= data_a;
	end 

	// Port B 
	always @ (posedge clk)
	begin
		if (we_b) 
			ram[wd_b] <= data_b;
	end
endmodule

/*
// память для обмена данными
// существует отдельная ячейка памяти для данных каждого процессора
// например, данные с процессора 2 запишутся в ячейку rd_2 = ram_ex[wd_2]
// ячейка 1 - локальная ячейка процессора 1, в которую он записывает свои обработанные данные
module sm_ram_exchange
#(parameter DATA_WIDTH_EX=37, parameter WD_WIDTH_EX=4)
(
	input [(DATA_WIDTH_EX-1):0] data_1, data_2, data_3, data_4, // вход данных от 1-4 процессоров
																// data_1 - данные назначаются процессору 1 и тд.
	input [(WD_WIDTH_EX-1):0] wd_1, wd_2, wd_3, wd_4, // судя по всему ячейки памяти, соответственно для процессоров 1-4
	
	input we_1, we_2, we_3, we_4, clk, // сигнал от процессоров 1-4 о том, что они хотят передать данные и их надо записать в память
	
	output [(DATA_WIDTH_EX-1):0] rd_1, rd_2, rd_3, rd_4 // выходной порт данных
);

	reg [DATA_WIDTH_EX-1:0] ram_ex[2**WD_WIDTH_EX-1:0]; // область памяти
	
	initial 
		begin
			$readmemh ("ram_ex.hex", ram_ex);
		end
		
	assign rd_1 = ram_ex[wd_1];
	assign rd_2 = ram_ex[wd_2];
	assign rd_3 = ram_ex[wd_3];
	assign rd_4 = ram_ex[wd_4];
	
	//Port 1 for 1 processor core
	always @ (posedge clk)
	begin
		if (we_1)
			ram_ex[wd_1] <= data_1;
	end
		
	//Port 2 for 2 processor core
	always @ (posedge clk)
	begin
		if (we_2)
			ram_ex[wd_2] <= data_2;
	end
	
	//Port 3 for 3 processor core
	always @ (posedge clk)
	begin
		if (we_3)
			ram_ex[wd_3] <= data_3;
	end
	
	//Port 4 for 4 processor core
	always @ (posedge clk)
	begin
		if (we_4)
			ram_ex[wd_4] <= data_4;
	end

endmodule	
*/