	jq poke_main
	db "FEX",0
poke_main:
	pop bc
	ex (sp),hl
	push bc
	ld a,(de)
	ld bc,.getbyte
	cp a,'b'
	jq z,.preinchl
	ld bc,.getshort
	cp a,'s'
	jq z,.preinchl
	ld bc,.getint
	cp a,'i'
	jq z,.preinchl
	ld bc,.getlong
	cp a,'l'
	jq z,.preinchl
	dec hl
	pop bc
.preinchl:
	push bc
	inc hl
	push hl
	call osrt.hexstr_to_int
	pop bc
	ld a,(de)
	
	ret ;return to the pushed handler
.getbyte:
	ld a,(hl)
	or a,a
	sbc hl,hl
	ld l,a
	ret
.getshort:
	ld de,(hl)
	ex.s hl,de
	ret
.getint:
	ld hl,(hl)
	ret
.getlong:
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	ld a,(de)
	ld e,a
	ret
