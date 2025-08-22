;@DOES Blit a rectangle of the current draw buffer to the display buffer.
;@INPUT HL rectangle X coordinate
;@INPUT E rectangle Y coordinate
;@INPUT BC rectangle width
;@INPUT A rectangle height
;@DESTROYS HL,DE,BC,AF
gfx_BlitRectangle:
    call gfx_Compute
.computed:
    push hl
    ld hl,LCD_WIDTH
    or a,a
    sbc hl,bc ; LCD_WIDTH - width
    ex (sp),hl ; restore source draw ptr, save post-copy line increment
    ex (sp),iy ; line increment -> iy, save iy
    push hl ; save source draw ptr
    ; compute offset between buffers
    ld hl,(ti.mpLcdUpbase)
    ld de,(cur_lcd_buffer)
    or a,a
    sbc hl,de
    pop de ; restore source draw pointer
    add hl,de ; (lcd - buf) + source -> dest
    ex hl,de
; hl -> place to copy from
; de -> place to draw to
.loop:
    push bc
	ldir
	lea bc,iy ; post-copy line increment
	add hl,bc
    ex hl,de
    add hl,bc
    ex hl,de
    pop bc
	dec a
	jr	nz,.loop
    pop iy
    ret
