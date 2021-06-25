
_blconfig_exe:
	jr .init
	db "TFX",0
	db 0
.init:
	or a,a
	sbc hl,hl
	add hl,sp
	ld ix,(hl)
.clear_key:
	xor a,a
	ld (bos.last_keypress),a
.loop:
	HandleNextThread
	ld a,(bos.last_keypress)
	cp a,ti.skMath
	jq z,.bl_up
	cp a,ti.skClear
	jq nz,.loop
	jp (ix)
.bl_up:
	ld hl,ti.mpBlLevel
	ld a,(hl)
	add a,8
	or a,$80
	ld (hl),a
	rra
	rra
	ld hl,(ti.mpLcdUpbase)
	ld de,319
	add hl,de
	and a,$1F
	ld c,$20
	jq z,.start_draw_loop2
	ld b,a
	ld a,c
	sub a,b
	ld c,a
	xor a,a
.draw_loop:
	ld (hl),a
	dec hl
	djnz .draw_loop
.start_draw_loop2:
	ld b,c
	ld a,$FF
.draw_loop2:
	ld (hl),a
	dec hl
	djnz .draw_loop2
	jq .clear_key
