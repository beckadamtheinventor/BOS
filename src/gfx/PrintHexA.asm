
gfx_PrintHexA:
	ld hl,ScrapMem
	ld c,a
	rlca
	rlca
	rlca
	rlca
	call .nibble
	ld (hl),a
	ld a,c
	call .nibble
	inc hl
	ld (hl),a
	inc hl
	ld (hl),0
	dec hl
	dec hl
	jp gfx_PrintString
.nibble:
	and a,$F
	cp a,10
	jr c,.underA
	add a,'A'-10
	ret
.underA:
	add a,'0'
	ret
