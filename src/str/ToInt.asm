;@DOES convert a base-10 string into a 32-bit integer.
;@INPUT int32_t str_ToInt(const char *str, char** end);
;@OUTPUT hl = number, *end = character where parsing stopped.
str_ToInt:
	ld hl,-2
	call ti._frameset
	xor a,a
	ld (ix-1),a
	ld (ix-2),a
	sbc hl,hl
	ld de,(ix+6)
	ld a,(de)
	cp a,'-'
	jr nz,.entry
	inc de
	set 0,(ix-2)
.entry:
	call .loop
	bit 0,(ix-2)
	call nz,.negate
	push hl
	ld hl,(ix+9)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.dont_write_end
	ld (hl),de
.dont_write_end:
	pop hl
	ld sp,ix
	pop ix
	ret
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
	ld (ix-1),c
	add hl,hl ;x2
	push hl
	add hl,hl ;x4
	add hl,hl ;x8
	pop bc
	add hl,bc ;x10
	ld bc,0
	ld c,a
	add hl,bc
	ld c,(ix-1)
	jr .loop

; input auhl, output euhl = -auhl
.negate:
	neg ; negate A
	ex hl,de
	or a,a
	sbc hl,hl
	sbc hl,de ; 0 - value
	dec a ; carry will always be set here unless value is 0, in which case this wouldn't be run anyways
    ld e,a
    ret
