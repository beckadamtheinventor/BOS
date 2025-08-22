;@DOES Swaps the display and draw buffers.
;@OUTPUT HL = new display buffer.
;@OUTPUT DE = new draw buffer.
gfx_SwapDraw:
    ld de,(ti.mpLcdUpbase)
    ld hl,(cur_lcd_buffer)
    ld (ti.mpLcdUpbase),hl
    ld (cur_lcd_buffer),de
    ret
