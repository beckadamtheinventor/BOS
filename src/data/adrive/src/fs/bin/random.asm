
; return a random 32-bit number
	jr random_main
	db "FEX",0
random_main:
	ld hl,-8
	call ti._frameset
	call bos.sys_Random32
	ld (ix-4),hl
	ld (ix-1),e
	ld a,(ix+6)
	dec a
	jr z,.no_args
	dec a
	jr z,.one_arg
	dec a
	jr nz,.info
.two_args:
	syscall _argv_1
	push hl
	call bos.str_ToInt
	pop bc
	ld (ix-8),hl
	syscall _argv_2
	push hl
	call bos.str_ToInt
	pop bc
	ld bc,(ix-8)
	xor a,a
	sbc hl,bc
	push hl
	pop bc
	ld hl,(ix-4)
	ld e,(ix-1)
	call ti._lremu
	ld bc,(ix-8)
	add hl,bc
	ld e,a
	jr .no_args
.one_arg:
	syscall _argv_1
	push hl
	call bos.str_ToInt
	ex (sp),hl
	pop bc
	ld hl,(ix-4)
	ld e,(ix-1)
	call ti._lremu
	jr .no_args
.no_args:
	ld a,mReturnLong or mReturnNotError
	ld (bos.return_code_flags),a
.done:
	ld sp,ix
	pop ix
	ret

.info:
	ld hl,.info_str
	call bos.gui_PrintLine
	jr .done

.info_str:
	db "random",$A
	db "random (max)",$A
	db "random (min) (max)"
	db 0
