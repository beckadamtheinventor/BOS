
	jr _bomasm_main
	db "FEX", 0
_bomasm_main:
	ld hl,-30
	call ti._frameset
	
	ld sp,ix
	pop ix
	ret
