;@DOES Ensure that the lcd to 8bpp mode. If not in 8bpp mode, clears vram.
;@DESTROYS Assume all.
gfx_Ensure8bpp:
    ;ld hl,(cur_lcd_buffer)
    ;ld (ti.mpLcdUpbase),hl
    ld a,(ti.mpLcdCtrl)
    cp a,ti.lcdBpp8
    ret z
    jq gfx_Set8bpp

