;@DOES draws a horizontal line to the current buffer
;@INPUT HL line X coordinate
;@INPUT E line Y coordinate
;@INPUT BC line length
;@DESTROYS HL,DE,BC,F(P/V)
gfx_HorizLine:
	call	gfx_Compute			; hl -> drawing location
.computed:
sys_MemSet:
	push de,hl
	pop de
	inc de
	ld (hl),a
	ldir
	pop de
	ret

