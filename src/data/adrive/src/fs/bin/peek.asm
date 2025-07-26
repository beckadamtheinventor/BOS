	jr peek_main
	db "FEX",0
peek_main:
	ld hl,-1
	call ti._frameset
	ld hl,bos.return_code_flags
	ld a,(hl)
	ld (ix-1),a
	or a,bos.mReturnHex+bos.mReturnNotError+bos.mReturnLong
	ld (hl),a
	ld a,(ix+6)
	cp a,3
	jr nz,.info
	syscall _argv_1
	ex hl,de
	ld hl,bos.return_code_flags
	ld a,(de)
	inc de
	ld c,4
	cp a,'l'
	jr z,.peek
	res bos.bReturnLong,(hl)
	dec c
	cp a,'i'
	jr z,.peek
	dec c
	cp a,'s'
	jr z,.peek
	dec c
	cp a,'b'
	jr nz,.info
.peek:
	push bc
	syscall _argv_2
	push hl
	syscall _intstr_to_int
	pop bc,bc
	ld a,c
	syscall _read_a_from_addr
	jr .done
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
	ld hl,bos.return_code_flags
	ld a,(ix-1)
	ld (hl),a
	or a,a
	sbc hl,hl
.done:
	ld sp,ix
	pop ix
	ret

.infostr:
	db "usage: peek [l|i|s|b] [addr]",$A
	db "read 32|24|16|8 bits from address.",0
	db "addr [[$]0-9A-F].",$A

