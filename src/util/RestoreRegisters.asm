;@DOES Restores all currently accessible registers from OP2 and OP3
;@OUTPUT bc,de,hl,ix,iy,af are all restored
util_RestoreRegisters:
	ld (ScrapMem),sp
	ld sp,fsOP2
	pop bc,de,hl,ix,iy,af
	ld sp,(ScrapMem)
	ret
