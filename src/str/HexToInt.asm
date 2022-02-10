str_HexToInt:
	pop bc,de
	push de,bc
.entry:
	or a,a
	sbc hl,hl
	ld c,l
.loop:
	ld a,(de)
	or a,a
	ret z
	cp a,'F'+1
	ccf
	ret c
	cp a,'A'
	jr nc,.between_af
	sub a,'0'
	ret c
	cp a,10
	ccf
	ret c
	jr .add_a
.between_af:
	sub a,'A'-10
.add_a:
	inc de
	ld b,a    ;b = (de)
	xor a,a
	add hl,hl ;auhl * 2
	adc a,c
	add hl,hl ;auhl * 4
	adc a,c
	add hl,hl ;auhl * 8
	adc a,c
	add hl,hl ;auhl * 16
	adc a,c
	ld c,a    ;cuhl = auhl
	ld a,l    ;l = l + b
	add a,b
	ld l,a
	jr .loop
