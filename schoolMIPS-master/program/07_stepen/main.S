			
			
			.text 
			
start: 		li $t0, 0x8 
			li $t1, 0x4 
			li $t2, 0x1 
			move $v0, $t0 

M1: 		beq $t1, $t2, finish 
			addiu $t1, $t1, -0x1 
			mul $v0, $v0, $t0 
			b M1 

finish: 	nop