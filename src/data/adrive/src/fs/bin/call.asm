
; unused for now, jump executable works as a call
	jr call_main
	db "FEX",0
call_main:
	call ti._frameset0
	syscall _argv_1
	ld bc,2
	push hl,bc
	call jump_main
	ld sp,ix
	pop ix
	ret
