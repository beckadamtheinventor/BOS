
;@DOES draws a 1 bit-per-pixel character sprite to the current lcd buffer
;@INPUT void gfx_SpriteChar(const uint8_t *sprite, unsigned int x, uint8_t y, uint8_t scale_x, uint8_t scale_y, uint8_t color);

gfx_SpriteChar:
	call ti._frameset0
	ld hl,(ix+9)
	ld de,(cur_lcd_buffer)
	add hl,de
	ld e,(ix+12)
	ld d,160
	mlt de
	add hl,de
	add hl,de
	ld d,0
	ld bc,(ix+6)
	ld a,8
.yloop:
	push af
	ld a,(bc)
	inc bc
	push bc
	ld b,8
	ld c,(ix+21)
	push hl
.xloop:
	ld e,(ix+15)
	add a,a
	jq nc,.next
.innerxloop:
	ld (hl),c
	inc hl
	dec e
	jq nz,.innerxloop
	db $1E ;ld e,...
.next:
	add hl,de
	djnz .xloop
	ex hl,de
	pop hl
	ld c,8
	ld b,(ix+15)
	mlt bc
	ld a,(ix+18)
	cp a,2
	jq c,.skipycopy
.inneryloop:
	push bc,bc
	ldir
	pop bc
	push hl
	ld hl,320
	or a,a
	sbc hl,bc
	push hl
	pop bc
	pop hl
	add hl,bc
	ex hl,de
	add hl,de
	ex hl,de
	pop bc
	dec a
	jq nz,.inneryloop
.skipycopy:
	pop bc,af
	dec a
	jq nz,.yloop
	pop ix
	ret

