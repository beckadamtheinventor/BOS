;@DOES set the lcd to 16bpp mode
;@DESTROYS HL,DE,BC,AF
gfx_Set16bpp:
	call ti.boot.ClearVRAM
	ld	a,ti.lcdBpp16
	ld	(ti.mpLcdCtrl),a
	ret

