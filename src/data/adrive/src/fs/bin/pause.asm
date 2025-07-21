
	jr pause_main
	db "FEX",0
pause_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,2
	jr c,.no_args
	syscall _argv_1
	ld a,(hl)
	cp a,'-'
	jr z,.help
.not_a_flag:
	push hl
	syscall _str_to_int
	pop bc
	jr .wait_for_key
.no_args:
	ld l,$FF
.wait_for_key:
	push hl
	call bos.sys_WaitKeyCycle
	pop hl
	inc l
	jr z,.return_a
	cp a,l
	jr nz,.wait_for_key
.return_a:
	ld hl,bos.return_code_flags
	set bos.bReturnNotError,(hl)
	or a,a
.exit_cf:
	sbc hl,hl
	ld l,a
	ld sp,ix
	pop ix
	ret

.help:
	ld hl,.str_HelpStr
	call bos.gui_PrintLine
	xor a,a
	jr .exit_cf

.str_HelpStr:
	db "Usage:",$A,$9,"pause [key]",$A,"if key is specified,",$A,"waits until that key is pressed.",0
