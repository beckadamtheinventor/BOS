;@DOES Backs up all currently accessible registers.
;@OUTPUT saves to OP2 and OP3
util_BackupRegisters:
	ld (ScrapMem),sp
	ld sp,fsOP2+18
	push af,iy,ix,hl,de,bc
	ld sp,(ScrapMem)
	ret
