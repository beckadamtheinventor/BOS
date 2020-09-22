;@DOES draws a horizontal line
;@INPUT HL line X coordinate
;@INPUT E line Y coordinate
;@INPUT BC line length
;@DESTROYS HL,DE,BC,F(P/V)
gfx_HorizLine:
	call	gfx_Compute			; hl -> drawing location
.computed:
	jp	sys_MemSet

