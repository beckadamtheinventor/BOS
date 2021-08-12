
; shared code for os executables

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

; input a number of bytes to read
; input hl address to read from
osrt.read_a_from_addr:
	dec a
	dec a
	jr z,osrt.read_word_from_addr
	dec a
	jr z,osrt.read_int_from_addr
	dec a
	jr z,osrt.read_long_from_addr
osrt.read_byte_from_addr:
	ld a,(hl)
	or a,a
	sbc hl,hl
	ld l,a
	ret
osrt.read_word_from_addr:
	ld de,(hl)
	ex.s hl,de
	ret
osrt.read_int_from_addr:
	ld hl,(hl)
	ret
osrt.read_long_from_addr:
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	ld a,(de)
	ld e,a
	ret

; input a number of bytes to write
; input hl address to write to
; input c|bc|ubc|eubc data to write
osrt.set_a_at_addr:
	dec a
	dec a
	jr z,osrt.set_word_at_addr
	dec a
	jr z,osrt.set_int_at_addr
	dec a
	jr z,osrt.set_long_at_addr
osrt.set_byte_at_addr:
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	ld (hl),c
osrt.return_cf:
	sbc hl,hl
	ret
osrt.set_word_at_addr:
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	inc hl
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	ld (hl),b
	dec hl
	ld (hl),c
	jr osrt.return_cf
osrt.set_int_at_addr:
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	inc hl
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	inc hl
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	dec hl
	dec hl
	ld (hl),bc
	ret
osrt.set_long_at_addr:
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	inc hl
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	inc hl
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	inc hl
	call osrt.check_address_writable
	jr c,osrt.return_neg_one
	ld (hl),e
	dec hl
	dec hl
	dec hl
	ld (hl),bc
	ret

osrt.return_neg_one:
	scf
	sbc hl,hl
	ret

osrt.check_address_writable:
	push hl,bc
	ld bc,$D00000
	or a,a
	sbc hl,bc
	jr c,osrt.popbchl_return
	ld bc,$D52C00 - $D00000
	sbc hl,bc
	ccf ;Cf set if address greater than $D52C00
	jr c,osrt.popbchl_return
	ld bc,ti.stackTop - $D52C00
	sbc hl,bc
	scf ;only affects Cf
	jr z,osrt.popbchl_return
	ccf
osrt.popbchl_return:
	pop bc,hl
	ret
