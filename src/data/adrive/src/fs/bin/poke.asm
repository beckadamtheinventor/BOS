	jq poke_main
	db "FEX",0
poke_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,4
	jr nz,.info
	call osrt.argv_1
	ld a,(hl)
	inc hl
	ld c,4
	cp a,'l'
	jr z,.poke
	dec c
	cp a,'i'
	jr z,.poke
	dec c
	cp a,'s'
	jr z,.poke
	dec c
	cp a,'b'
	jr nz,.info
.poke:
	ld a,c
	ld (bos.fsOP6+8),a
	push hl
	call osrt.hexstr_to_int ; address
	pop bc
	jr c,.done
	ld (bos.fsOP6),hl
	ld (bos.fsOP6+3),a
	call osrt.argv_3
	push hl
	call osrt.hexstr_to_int ; value to write
	pop bc
	ld (bos.fsOP6+4),hl
	ld (bos.fsOP6+7),a
	call osrt.argv_2
	ld a,(hl)
	ld hl,(bos.fsOP6)
	ld bc,(bos.fsOP6+4)
	ld de,(bos.fsOP6+7) ; e is value uppermost byte, d is number of bytes to write
	cp a,'='
	jr z,.poke_set
	cp a,'^'
	jr z,.poke_xor
	cp a,'|'
	jr z,.poke_or
	cp a,'&'
	jr z,.poke_and
.info:
	ld hl,.infostr
	call bos.gui_PrintLine
	or a,a
	sbc hl,hl
	jr .exit
.poke_xor:
	ld a,d
	call osrt.xor_val_addr
	jr .poke_set_from_eubc
.poke_or:
	ld a,d
	call osrt.or_val_addr
	jr .poke_set_from_eubc
.poke_and:
	ld a,d
	call osrt.and_val_addr
.poke_set_from_eubc:
	ld a,(bos.fsOP6+8)
	ld hl,(bos.fsOP6+4)
	call osrt.set_a_at_addr
.poke_set:
	ld a,d
	call osrt.set_a_at_addr
.done:
	sbc hl,hl
.exit:
	ld sp,ix
	pop ix
	ret

.infostr:
	db "usage:",$A
	db "poke [l|i|s|b][addr] [=^|&] [val]",$A
	db "Writes 4|3|2|1 bytes to address from val.",$A
	db "operators [=^|&] are set|xor|or|and.",$A
	db "addr and val are read in hex.",$A
	db 0
