	jr varptr_main
	db "FEX",0
varptr_main:
	call ti._frameset0
	ld hl,(ix+6)
	ld sp,ix
	pop ix
	ret
