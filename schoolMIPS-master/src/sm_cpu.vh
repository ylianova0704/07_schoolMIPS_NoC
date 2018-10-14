/*
 * schoolMIPS - small MIPS CPU for "Young Russian Chip Architects" 
 *              summer school ( yrca@googlegroups.com )
 *
 * originally based on Sarah L. Harris MIPS CPU 
 * 
 * Copyright(c) 2017 Stanislav Zhelnio 
 *                   Alexander Romanov 
 */ 

//ALU commands
`define ALU_ADD     3'b000
`define ALU_OR      3'b001
`define ALU_LUI     3'b010
`define ALU_SRL     3'b011
`define ALU_SLTU    3'b100
`define ALU_SUBU    3'b101
`define ALU_MUL     3'b110
`define ALU_SLTIU   3'b111
`define ALU_SLLV    4'b1000
`define ALU_J       4'b1001
`define ALU_DIP		4'b1010
`define ALU_XOR     4'b1011
//for RAM
`define ALU_SW      4'b1100
`define ALU_LW      4'b1101
//
`define ALU_AND     4'b1110

//diplom
`define ALU_SEND	4'b1111   // receives data from the router
`define ALU_GET		5'b10000  // sends data to the router

//instruction operation code
`define C_SPEC      6'b000000 // Special instructions (depends on function field), 
							  // XOR, AND
`define C_SPEC2     6'b011100 // Special instructions for MUL
`define C_ADDIU     6'b001001 // I-type, Integer Add Immediate Unsigned
                              //         Rd = Rs + Immed
`define C_BEQ       6'b000100 // I-type, Branch On Equal
                              //         if (Rs == Rt) PC += (int)offset
`define C_LUI       6'b001111 // I-type, Load Upper Immediate
                              //         Rt = Immed << 16
`define C_BNE       6'b000101 // I-type, Branch on Not Equal
                              //         if (Rs != Rt) PC += (int)offset
`define C_SLTIU		6'b001011 // I-type, Set on Less Than Immediate Unsigned
					          //         Rt = (Rs < Immediate) ? 1 : 0
`define C_J			6'b000010 // I-type, Jump
							  //		 J target 							  
`define C_DIP		6'b111111 // Special instruction for DIP
`define C_LW        6'b100011 // Memory, Load Word
							  //         Rt ← memory[base + offset]
`define C_SW		6'b101011 // Memory, Store Word
							  //         memory[base + offset] ← Rt
							  
//diplom
`define C_SEND		6'b110111 // Special instruction for SEND operation
`define C_GET		6'b111011 // Special instruction for GET operation
							  

							  

//instruction function field
`define F_ADDU      6'b100001 // R-type, Integer Add Unsigned
                              //         Rd = Rs + Rt
`define F_OR        6'b100101 // R-type, Logical OR
                              //         Rd = Rs | Rt
`define F_SRL       6'b000010 // R-type, Shift Right Logical, MUL
                              //         Rd = Rs∅ >> shift
`define F_SLTU      6'b101011 // R-type, Set on Less Than Unsigned
                              //         Rd = (Rs∅ < Rt∅) ? 1 : 0
`define F_SUBU      6'b100011 // R-type, Unsigned Subtract
                              //         Rd = Rs – Rt	
`define F_SLLV      6'b000100 // R-type, Shift Word Left Logical Variable
							  //         Rd = Rt << Rs
`define F_XOR		6'b100110 // R-type, Exclusive OR
							  //		 Rd = Rs xor Rt
`define F_AND		6'b100100 // R-type, And
							  //         Rd = Rs and Rt
`define F_ANY       6'b?????? // Use if no function field
