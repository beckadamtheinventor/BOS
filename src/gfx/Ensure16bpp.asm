;@DOES Ensure that the lcd to 8bpp mode. If not in 16bpp mode, clears vram.
;@DESTROYS HL,DE,BC,AF
gfx_Ensure16bpp:
    ld a,(ti.mpLcdUpbase)
    cp a,ti.lcdBpp16
    ret z
    jq gfx_Set16bpp

