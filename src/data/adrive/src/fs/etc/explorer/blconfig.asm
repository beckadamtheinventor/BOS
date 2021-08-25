
_blconfig_exe:
	jr .init
	db "TFX",0
	db 0
.init:
	pop ix
.loop:
	HandleNextThread
	ld a,(bos.last_keypress)
	cp a,ti.skMath
	jr nz,.loop
.loop2:
	HandleNextThread
	ld a,(bos.last_keypress)
	cp a,ti.skMath
	jr nz,.loop
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
	jr z,.start_draw_loop2
	ld b,a
	ld a,c
	sub a,b
	ld c,a
	ld a,(bos.lcd_bg_color)
.draw_loop:
	ld (hl),a
	dec hl
	djnz .draw_loop
.start_draw_loop2:
	ld b,c
	ld a,(bos.lcd_text_fg)
.draw_loop2:
	ld (hl),a
	dec hl
	djnz .draw_loop2
	jr .loop2

; Why the hell I put this here is to be discovered, but I doubt anyone will ever know what it means... hell I don't even remember what I did to make this.
	db $D4, $29, $C1, $CD, $FD, $51, $29, $15, $ED, $D1, $CD, $39, $51, $29, $D9, $C9, $4D, $4D, $ED, $15, $51, $ED
assert $-_blconfig_exe < 512
