	jr peek_main
	db "FEX",0
peek_main:
	pop bc,de
	push de,bc
	ld hl,bos.return_code_flags
	ld a,(hl)
	push hl,af
	set bos.bReturnHex,a
	set bos.bReturnNotError,a
	set bos.bReturnLong,a
	ld (hl),a
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
	push de
	call osrt.hexstr_to_int
	pop bc,bc
	ld a,c
	call osrt.read_a_from_addr
	pop bc,bc
	ret
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
	pop af,hl
	ld (hl),a
	or a,a
	sbc hl,hl
	ret

.infostr:
	db "usage: peek [l|i|s|b][addr]",$A
	db "read 32|24|16|8 bits from address.",0
	db "addr is interpreted in hexadecimal.",$A

