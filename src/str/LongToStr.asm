;@DOES Convert 32-bit signed integer num to a base-10 string.
;@INPUT char *str_LongToStr(char *dest, uint32_t num);
str_LongToStr:
	push iy
	ld iy,0
	add iy,sp
	ld hl,(iy+9)
	ld a,(iy+12)
	ld iy,(iy+6)
	bit 7,a
	call nz,.negative
	pop bc
	push iy,bc
	ld e,1000000000 shr 24
	ld bc,1000000000 and $FFFFFF
	call .aqu
	ld e,100000000 shr 24
	ld bc,100000000 and $FFFFFF
	call .aqu
	ld e,0
.10m:
	ld bc,10000000
	call .aqu
	ld bc,1000000
	call .aqu
	ld bc,100000
	call .aqu
.10k:
	ld bc,10000
	call .aqu
	ld bc,1000
	call .aqu
.100:
	ld bc,100
	call .aqu
	ld c,10
	call .aqu
	ld c,1
	call .aqu
	ld (iy),0
	pop iy,hl
	ld a,(hl)
	cp a,'-'
	ld b,a
	jr nz,.skip_zeroes_loop
	inc hl
.skip_zeroes_loop:
	ld a,(hl)
	or a,a
	jr z,.return_single_zero
	cp a,'0'
	jr nz,.finish_returning_string
	inc hl
	jr .skip_zeroes_loop
.return_single_zero:
	dec hl
.finish_returning_string:
	ld a,b
	cp a,'-'
	ret nz
	dec hl
	ld (hl),a
	ret

.aqu:
	ld d,'0'-1
.aqu.loop:
	inc d
	or a,a
	sbc hl,bc
	sbc a,e
	jr nc,.aqu.loop
	add hl,bc
	adc a,e
	ld (iy),d
	inc iy
	ret

.negative:
	neg ; negate A
	ex hl,de
	or a,a
	sbc hl,hl
	sbc hl,de ; 0 - value
	dec a ; carry will always be set here unless value is 0, in which case this wouldn't be run anyways
	; sbc a,0 ; subtract 1 from A
	ld (iy),'-'
	inc iy
	ret
