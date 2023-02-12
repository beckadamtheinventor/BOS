
	jr _zx7_main
	db "FEX",0
_zx7_main:
	ld hl,-29
	call ti._frameset
	call osrt.argv_1
	ld a,l
	or a,a
	jr z,.passed_int_args
	call osrt.argv_2
	push hl
	call osrt.hexstr_to_int
	ex (sp),hl
	call osrt.argv_3
	push hl
	call osrt.hexstr_to_int
	ex (sp),hl
	call osrt.argv_4
	push hl
	call osrt.hexstr_to_int
	jr .entry
.passed_int_args:
	call osrt.argv_2
	push hl
	call osrt.argv_3
	push hl
	call osrt.argv_4
.entry:
	ex (sp),hl
	pop bc,de
	ld (ix-3),hl
	ld (ix-23),$80
	ld a,(hl)
	ld (de),a
	inc de
	ld (ix-22),de
	inc hl
	dec bc
	ld (ix-26),bc
.compressloop:
	ld (ix-6),hl
	call .locatepattern
	ld hl,(ix-6)
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

	push bc, de
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
	pop de,bc
	push bc,de
	jp .locatepatternloop
.locatedliteral:
	ld hl,(ix-12)
	ld bc,$090000
	xor a,a
	sbc hl,bc
	add hl,bc
	jr nc,.writeliteral
	ld hl,2
	ld bc,(ix-15) ; length
	dec bc
	pop de
	push de
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
	pop de
	pop bc
	ld (de),a
	inc de
	ret

.write_offset_over_128:
	ld a,l
	and a,$7F
	or a,$80
.
	
	pop de
	pop bc
	ret
.writeliteral:
	pop de
	ld c,a
	call .writezerobit
	ld a,c
	pop bc
	ld (de),a
	inc de
	ret

.writebit:
	jr z,.writezerobit
	ld a,(ix-23)
	ld iy,(ix-22)
	or a,(iy)
	ld (iy),a
.writezerobit:
	rr (ix-23)
	ret nc
	ld (ix-22),de
	ld (ix-23),$80
	ret

