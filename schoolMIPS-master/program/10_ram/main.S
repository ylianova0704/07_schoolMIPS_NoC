.text

start:		
			li $t0, 0x6 # size of an array
			li $t1, 0x1 
			li $v1, 0x0 # base of an array
			li $t5, -0x1
			
L0:
			# for i = 1, i <= n - 1 (initialize values)
			li $t2, 0 # i = 0
			li $v1, 0 # A = 0 (pointer to begin of the array)
			
L1:			
			lw $t3, 0x0($v1) # get A[i]
			and $t4, $t3, $t1 # logic AND
			beq $t4, $t1, L2 # if last bit == 1 -> goto L2
			b L3
			
L2:			
			#mul $t3, $t3, $t5
			subu $t6, $t3, $t3
			subu $t3, $t6, $t3
			sw $t3, 0x0($v1)
			b L3
			
L3:			
			addiu $v1, $v1, 0x4 # A++
			addiu $t2, $t2, 0x1 # i++	
			b L1
			
L4:			
			beq $t0, $t2, finish
			
finish:
			nop
