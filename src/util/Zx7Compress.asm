;@DOES Zx7 compress a block of memory.
;@INPUT int util_Zx7Compress(void *dest, void *src, int len, void (*progress_callback)(int src_offset));
;@OUTPUT length in bytes written to dest.
util_Zx7Compress:
	ld hl,-29
	call ti._frameset
	ld hl,(ix+9)
	ld bc,(ix+6)
	ld de,(ix+3)
	ld (ix-3),hl
	ld (ix-23),$80
	ld a,(hl)
	ld (de),a
	inc de
	ld (ix-22),de
	inc de
	inc hl
	dec bc
.compressloop:
	ld (ix-32),de
	ld (ix-26),bc
	ld (ix-6),hl
	call .locatepattern
	ld hl,(ix-6)
	ld de,(ix-32)
	ld bc,(ix-26)
	cpi
	jp pe,.compressloop
	ld sp,ix
	pop ix
	ret

.locatepattern:
	ld a,(hl)
	dec hl
	ld (ix-9),hl
	ld hl,$090000
	ld (ix-12),hl
	ld l,1
	ld (ix-15),hl
	ld (ix-18),hl

	ld hl,(ix-9)
	ld de,(ix-3)
	sbc hl,de
	push hl
	pop bc
	add hl,de
.locatepatternloop:
	cpdr
	jp po, .locatedliteral
	push hl
	pop iy
	ld de,(ix-6)
	push bc
	ld hl,(ix-6)
	ld bc,$010000
	add hl,bc
	ld bc,(ix-26)
.patterncheckloop:
	dec bc
	ld a,b
	or a,c
	jr z,.donepatternloop
	sbc hl,de
	add hl,de
	jr nc,.donepatternloop
	inc de
	inc iy
	ld a,(de)
	cp a,(iy)
	jr z,.patterncheckloop
.donepatternloop:
	ex hl,de
	ld de,(ix-6)
	sbc hl,de ; hl = pattern length
	ld (ix-29),hl
	dec hl
	ld a,10
.costloop:
	add a,2
	rr h
	rr l
	jr nz,.costloop
	lea hl,iy
	or a,a
	sbc hl,de ; hl = pattern offset
	push hl
	ld de,129
	sbc hl,de
	jr c,.offsetunder128
	add a,4
.offsetunder128:
	; divide cost by length
	; TODO: optimize this somehow
	ld h,a
	ld l,0
	ld b,8
.shift_up_8_loop:
	add hl,hl
	djnz .shift_up_8_loop
	ld bc,(ix-29)
	call ti._idivu
	ld bc,(ix-12) ; pattern length
	or a,a
	sbc hl,bc
	add hl,bc
	jr nc,.dontsetcost
	ld (ix-12),hl ; cost
	ld hl,(ix-29)
	ld (ix-15),hl ; length
	pop hl
	ld (ix-18),hl ; offset
	db $3e ; ld a,... dummify pop bc
.dontsetcost:
	pop bc,bc
	jp .locatepatternloop

.locatedliteral:
	ld hl,(ix-12)
	ld bc,$090000
	xor a,a
	sbc hl,bc
	add hl,bc
	jr nc,.writeliteral ; write literal if it's more efficient
	ld hl,2
	ld bc,(ix-15) ; length
	dec bc
.writezerobitsloop:
	call .writezerobit
	add hl,hl
	sbc hl,bc
	add hl,bc
	jr c,.writezerobitsloop
	ex hl,de
	ld hl,(ix-15) ; length
	dec hl
.writelengthbitsloop:
	rr d
	rr e
	sbc hl,de
	add hl,de
	jr z,.donewritinglengthbits
	jr c,.writelengthbitsloop
	or a,1
	call .writebit
	jr .writelengthbitsloop
.donewritinglengthbits:
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
	ret

.writeliteral:
	ld c,a
	call .writezerobit
	ld a,c
	ld (de),a
	inc de
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
	or a,1
	sbc hl,bc
	jr c,.write_offset_over_128_loop_dont_write_bit
	call .writebit
	db $3E ; dummify next instruction
.write_offset_over_128_loop_dont_write_bit:
	add hl,bc
	rr b
	jr nz,.write_offset_over_128_loop_dontexit
	jr c,.write_offset_over_128_loop_dontexit
	bit 7,c
	ret z
	; jr z,.write_offset_over_128_loop_exit
.write_offset_over_128_loop_dontexit:
	rr c
	jr .write_offset_over_128_loop
; .write_offset_over_128_loop_exit:
	; ret

.writebit:
	jr z,.writezerobit
	ld a,(ix-23)
	ld iy,(ix-22)
	or a,(iy)
	ld (iy),a
.writezerobit:
	rr (ix-23)
	ret nc
	ld a,(ix-23)
	ld (ix-22),de
	ld (de),a
	inc de
	ld (ix-23),$80
	ret

