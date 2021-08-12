	jq poke_main
	db "FEX",0
poke_main:
	pop bc
	ex (sp),hl
	push bc
	ld a,(hl)
	ld c,1
	cp a,'b'
	jq z,.preinchl
	inc c
	cp a,'s'
	jq z,.preinchl
	inc c
	cp a,'i'
	jq z,.preinchl
	inc c
	cp a,'l'
	jq z,.preinchl
	ld c,1
	dec hl
.preinchl:
	inc hl
	push hl
	call osrt.hexstr_to_int
	pop bc
	sbc hl,hl
	ret
