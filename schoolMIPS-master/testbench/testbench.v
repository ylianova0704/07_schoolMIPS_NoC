
`timescale 1 ns / 100 ps

`include "sm_cpu.vh"

module sm_testbench;

    // simulation options
    parameter Tt     = 20;
    parameter Ncycle = 1000;

    reg         clk;
    reg         rst_n;
    reg  [ 4:0] regAddr;
    wire [31:0] regData;
	reg  [ 4:0] ramAddr;
	wire [31:0] ramData;

    // ***** DUT start ************************

    //instruction memory
    wire    [31:0]  imAddr;
    wire    [31:0]  imData;
    sm_rom reset_rom(imAddr, imData);

    //cpu core
    sm_cpu sm_cpu
    (
        .clk     ( clk     ),
        .rst_n   ( rst_n   ),
        .regAddr ( regAddr ),
        .regData ( regData ),
        .imAddr  ( imAddr  ),
        .imData  ( imData  ),
		.dipValue( dipValue),
		.ramAddr ( ramAddr ),
		.ramDataB( ramData )	
    );

    // ***** DUT  end  ************************

`ifdef ICARUS
    //iverilog memory dump init workaround
    initial $dumpvars;
    genvar k;
    for (k = 0; k < 32; k = k + 1) begin
        initial $dumpvars(0, sm_cpu.rf.rf[k]);
    end
`endif

    // simulation init
    initial begin
        clk = 0;
        forever clk = #(Tt/2) ~clk;
    end

    initial begin
        rst_n   = 0;
        repeat (4)  @(posedge clk);
        rst_n   = 1;
    end

    //register file reset
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            sm_cpu.rf.rf[i] = 0;
    end
	
	task dumpRam
    (
    );
        integer i;
        begin
            $write("--- RAM Dump ---\n");
            for (i = 0; i < 16; i = i + 1)
                $write("ram[%1x] = %1h\n", i, sm_cpu.sm_ram_memory.ram[i]);
        end
    endtask

    task disasmInstr
    (
        input [31:0] instr
    );
        reg        [ 5:0] cmdOper;
        reg        [ 5:0] cmdFunk;
        reg        [ 4:0] cmdRs;
        reg        [ 4:0] cmdRt;
        reg        [ 4:0] cmdRd;
        reg        [ 4:0] cmdSa;
        reg        [15:0] cmdImm;
        reg signed [15:0] cmdImmS;
		reg        [25:0] cmdJumpAddr;

        begin
            cmdOper = instr[31:26];
            cmdFunk = instr[ 5:0 ];
            cmdRs   = instr[25:21];
            cmdRt   = instr[20:16];
            cmdRd   = instr[15:11];
            cmdSa   = instr[10:6 ];
            cmdImm  = instr[15:0 ];
            cmdImmS = instr[15:0 ];
			cmdJumpAddr = instr[25:0];

            $write("   ");

            casez( {cmdOper,cmdFunk} )
                default               : if (instr == 32'b0) 
                                            $write ("nop");
                                        else
                                            $write ("new/unknown");

                { `C_SPEC,  `F_ADDU } : $write ("addu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_OR   } : $write ("or    $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SRL  } : $write ("srl   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SLTU } : $write ("sltu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
                { `C_SPEC,  `F_SUBU } : $write ("subu  $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
				{ `C_SPEC2, `F_SRL  } : $write ("mul   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
				{ `C_SPEC,  `F_SLLV } : $write ("sllv  $%1d, $%1d, $%1d", cmdRd, cmdRt, cmdRs);
				{ `C_SPEC,  `F_XOR  } : $write ("xor   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);
				{ `C_SPEC,  `F_AND  } : $write ("and   $%1d, $%1d, $%1d", cmdRd, cmdRs, cmdRt);

                { `C_ADDIU, `F_ANY  } : $write ("addiu $%1d, $%1d, %1d", cmdRt, cmdRs, cmdImm);
                { `C_LUI,   `F_ANY  } : $write ("lui   $%1d, %1d",       cmdRt, cmdImm);
				{ `C_SLTIU, `F_ANY  } : $write ("sltiu $%1d, $%1d, %1d", cmdRt, cmdRs, cmdImm);

                { `C_BEQ,   `F_ANY  } : $write ("beq   $%1d, $%1d, %1d", cmdRs, cmdRt, cmdImmS + 1);
                { `C_BNE,   `F_ANY  } : $write ("bne   $%1d, $%1d, %1d", cmdRs, cmdRt, cmdImmS + 1);
				{ `C_J,     `F_ANY  } : $write ("j     %1d",             cmdJumpAddr);
				{ `C_DIP,   `F_ANY  } : $write ("dip   $%1d, %1d",       cmdRd, cmdImm);
				
				{ `C_LW,    `F_ANY  } : $write("lw     $%1d, %1d(%1d)", cmdRt, cmdImmS, cmdRs);
				{ `C_SW,    `F_ANY  } : $write("sw     $%1d, %1d(%1d)", cmdRt, cmdImmS, cmdRs);
            
				//{ `C_SEND,  `F_ANY  ) : $write("send	"); //команда send
				//{ `C_GET,	`F_ANY  ) : $write("get		"); //команда get
			endcase
        end

    endtask


    //simulation debug output
    integer cycle; initial cycle = 0;

    initial regAddr = 0; // get PC

    always @ (posedge clk)
    begin
        $write ("%5d  pc = %2d  pcaddr = %h  instr = %h   t3 = %1d  v1=%1d", 
                  cycle, regData, (regData << 2), sm_cpu.instr, sm_cpu.rf.rf[2], sm_cpu.rf.rf[3]);

        disasmInstr(sm_cpu.instr);

        $write("\n");

        cycle = cycle + 1;

        if (cycle > Ncycle)
        begin
			dumpRam();
            $display ("Timeout");
            $stop;
        end
    end

endmodule
