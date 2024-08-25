
; return a random 32-bit number
	jr random_main
	db "FEX",0
random_main:
	ld a,mReturnLong or mReturnNotError
	ld (bos.return_code_flags),a
	jp bos.sys_Random32
