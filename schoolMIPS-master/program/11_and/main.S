#
#
#            .text 
#
#start: 		li $v0, 0
#
#			li $t0, 0x0111
#			li $t1, 0x1110
#			xor $v0, $t0, $t1

			.text

start:		li $v0, 0x110
			li $t0, 0x0111
			and $v0, $t0