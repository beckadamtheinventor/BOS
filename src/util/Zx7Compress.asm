;@DOES Zx7 compress a block of memory.
;@INPUT int util_Zx7Compress(void *dest, void *src, int len, void (*progress_callback)(int src_offset));
;@OUTPUT length in bytes written to dest.
util_Zx7Compress:
	ld hl,-39
	call ti._frameset
	ld hl,(ix+9)
	ld bc,(ix+12)
	ld de,(ix+6)
	ld (ix-3),hl
	ld (ix-23),0
	ld (ix-39),8
	ld a,(hl)
	ld (de),a
	inc de
	ld (ix-22),de
	inc de
	inc hl
	dec bc
	ld (ix-6),hl
	ld (ix-32),de
	ld (ix-26),bc
.compressloop:
	call .locate_pattern
	call .write_pattern_or_literal
	ld bc,(ix-26)
	ld a,(ix+2-26)
	or a,b
	or a,c
	jr nz,.compressloop

	scf
	call .write_bit
	ld b,16
.terminus_loop:
	or a,a
	call .write_bit
	djnz .terminus_loop
	scf
	call .write_bit
	
.shift_final_byte:
	call .write_zero_bit
	jr nz,.shift_final_byte

	ld hl,(ix-32)
	ld bc,(ix+6)
	or a,a
	sbc hl,bc
	ld sp,ix
	pop ix
	ret

.locate_pattern:
	ld hl,(ix-6)
	ld a,(hl)
	dec hl
	; ld (ix-9),hl
	push hl
	ld hl,$090000
	ld (ix-12),hl
;	ld hl,1
	mlt hl
	inc l
	ld (ix-15),hl
	ld (ix-18),hl

	; ld hl,(ix-9)
	pop hl
	ld de,(ix-3)
	or a,a
	sbc hl,de
	push hl
	push hl
	ld bc,2176
	or a,a
	sbc hl,bc
	pop hl
	pop bc
	inc bc
	jr c,.under_max_offset
	ld bc,2176
.under_max_offset:
	add hl,de
.locate_pattern_loop:
	cpdr
	ret po
	ld (ix-35),hl
	ld (ix-38),bc
	inc hl
.located_pattern:
	ld iy,(ix-6) ; read ptr
	push hl
	pop de
	ld bc,65536 ; max offset
	add hl,bc
	ld bc,(ix-26)
.pattern_check_loop:
	dec bc
	ld a,b
	or a,c
	jr z,.done_pattern_loop
	sbc hl,de
	add hl,de
	jr c,.done_pattern_loop
	inc de
	inc iy
	ld a,(de)
	cp a,(iy)
	jr z,.pattern_check_loop
.done_pattern_loop:
	lea hl,iy
	ld de,(ix-6)
	scf
	sbc hl,de ; hl = pattern length - 1
	ld (ix-29),hl
	ld a,h
	or a,l
	ret z
	ld a,10
.cost_loop:
	add a,2
	rr h
	rr l
	jr nz,.cost_loop
	lea hl,iy
	or a,a
	sbc hl,de ; hl = pattern offset
	push hl
	ld de,129
	sbc hl,de
	jr c,.offset_under_128
	add a,4
.offset_under_128:
	; divide cost by length
	; TODO: optimize this somehow
	ld h,a
	ld l,0
	ld b,8
.shift_up_8_loop:
	add hl,hl
	djnz .shift_up_8_loop
	ld bc,(ix-29)
	inc bc
	call ti._idvrmu
	ex de,hl
	ld bc,(ix-12) ; pattern length
	or a,a
	sbc hl,bc
	add hl,bc
	jr nc,.dont_set_cost
	ld (ix-12),hl ; cost
	ld hl,(ix-29)
	inc hl
	ld (ix-15),hl ; length
	pop hl
	ld (ix-18),hl ; offset
	db $3e ; ld a,... dummify pop bc
.dont_set_cost:
	pop bc
	ld hl,(ix-35)
	ld bc,(ix-38)
	jp .locate_pattern_loop

.write_literal:
	ld de,(ix-32)
	call .write_zero_bit
	ld hl,(ix-6)
	ld a,(hl)
	inc hl
	ld (ix-6),hl
	ld (de),a
	inc de
	ld (ix-32),de
	ld hl,(ix-26)
	dec hl
	ld (ix-26),hl
	ret

.write_pattern_or_literal:
	ld hl,(ix-12)
	ld bc,$090000
	xor a,a
	sbc hl,bc
	add hl,bc
	jr nc,.write_literal ; write literal if it's more efficient
	scf
	call .write_bit
	ld hl,2
	ld bc,(ix-15) ; length
	dec bc
.write_zero_bits_loop:
	call .write_zero_bit
	add hl,hl
	scf
	sbc hl,bc
	add hl,bc
	jr c,.write_zero_bits_loop
	ld b,h
	ld c,l
	ld hl,(ix-15) ; length
	dec hl
.write_length_bits_loop:
	or a,a
	rr b
	rr c
	ld a,b
	or a,c
	jr z,.done_writing_length_bits
	ld a,b
	and a,h
	ld e,a
	ld a,c
	and a,l
	or a,e
	scf
	jr nz,._write_1_bit
	ccf
._write_1_bit:
	call .write_bit
	jr .write_length_bits_loop
.done_writing_length_bits:
	ld hl,(ix-18) ; offset
	dec hl
	ld de,128
	or a,a
	sbc hl,de
	jr nc,.write_offset_over_128
	add hl,de
	ld a,l
	ld de,(ix-32)
	ld (de),a
	inc de
	ld (ix-32),de
.finished_writing_pattern:
	ld bc,(ix-15)
	ld hl,(ix-6)
	add hl,bc
	ld (ix-6),hl
	ld hl,(ix-26)
	or a,a
	sbc hl,bc
	ld (ix-26),hl
	ret

.write_offset_over_128:
	ld a,l
	and a,$7F
	or a,$80
	ld de,(ix-32)
	ld (de),a
	inc de
	ld (ix-32),de
	ld bc,1024
.write_offset_over_128_loop:
	or a,a
	sbc hl,bc
	jr c,.write_offset_over_128_loop_dont_write_bit
	scf
	call .write_bit
	db $3E ; dummify next instruction
.write_offset_over_128_loop_dont_write_bit:
	add hl,bc
	rr b
	jr nz,.write_offset_over_128_loop_dontexit
	jr c,.write_offset_over_128_loop_dontexit
	bit 7,c
	jr z,.finished_writing_pattern
	; jr z,.write_offset_over_128_loop_exit
.write_offset_over_128_loop_dontexit:
	rr c
	jr .write_offset_over_128_loop
; .write_offset_over_128_loop_exit:
	; ret

.write_zero_bit:
	or a,a
.write_bit:
	sla (ix-23)
	dec (ix-39)
	ret nz
	ld a,(ix-23)
	ld de,(ix-22)
	ld (de),a
	ld (ix-39),8
	ld de,(ix-32)
	ld (ix-22),de
	inc de
	ld (ix-32),de
	ret

