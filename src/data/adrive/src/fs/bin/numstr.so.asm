
; shared str<-->num code for os executables

	jp osrt.str_to_int
	jp osrt.hexstr_to_int
	jp osrt.nibble
	jp osrt.byte_to_hexstr
	jp osrt.int_to_hexstr
	jp osrt.long_to_hexstr

osrt.str_to_int:
	pop bc,de
	push de,bc
	or a,a
	sbc hl,hl
.loop:
	ld a,(de)
	or a,a
	ret z
	sub a,'0'
	ret c
	cp a,10
	ccf
	ret c
	inc de
	add hl,hl ;x2
	push hl
	add hl,hl ;x4
	add hl,hl ;x8
	pop bc
	add hl,bc ;x10
	ld bc,0
	ld c,a
	add hl,bc
	jr .loop

osrt.hexstr_to_int:
	pop bc,de
	push de,bc
	or a,a
	sbc hl,hl
	ld c,l
	call osrt.hexstr_to_int.loop
	ld a,c
	ret

osrt.hexstr_to_int.loop:
	ld a,(de)
	or a,a
	ret z
	cp a,'G'
	ccf
	ret c
	cp a,'A'
	jr nc,osrt.hexstr_to_int.between_af
	sub a,'0'
	ret c
	cp a,10
	ccf
	ret c
	jr osrt.hexstr_to_int.add_a
osrt.hexstr_to_int.between_af:
	sub a,'A'-10
osrt.hexstr_to_int.add_a:
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
	jr osrt.hexstr_to_int.loop

; input hl pointer to number
; input de pointer to output buffer
osrt.long_to_hexstr:
	ld b,4
	inc hl
	inc hl
	db $01 ;dummify next 3 bytes

; input hl pointer to number
; input de pointer to output buffer
osrt.int_to_hexstr:
	ld b,3
	inc hl
	inc hl ;osrt.long_to_hexstr will enter here
osrt.int_to_hexstr.loop:
	call osrt.byte_to_hexstr
	djnz osrt.int_to_hexstr.loop
	ret

; input hl pointer to input
; input de pointer to output
osrt.byte_to_hexstr:
	ld a,(hl)
	rrca
	rrca
	rrca
	rrca
	call osrt.nibble
	ld (de),a
	inc de
	ld a,(hl)
	dec hl
	call osrt.nibble
	ld (de),a
	inc de
	ret

; input a nibble (upper 4 bits are ignored)
; output a hex character
osrt.nibble:
	and a,$F
	cp a,10
	jq nc,osrt.nibble.over9
	add a,'0'
	ret
osrt.nibble.over9:
	add a,'A'-10
	ret