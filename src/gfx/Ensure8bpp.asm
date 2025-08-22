;@DOES Ensure that the lcd to 8bpp mode. If not in 8bpp mode, clears vram.
;@DESTROYS HL,DE,BC,AF
gfx_Ensure8bpp:
    ld a,(ti.mpLcdCtrl)
    cp a,ti.lcdBpp8
    ret z
    jq gfx_Set8bpp

