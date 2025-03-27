;@DOES Read flash sector A into the sector cache (VRAM)
;@OUTPUT returns pointer to sector cache in hl
sys_ReadSectorCache:
	pop bc,hl
	push hl,bc
	ld a,l
.entry:
    call .only_handle_vram
	push af
	dec sp
	pop hl
	inc sp
	ld bc,$010000
	ld l,c
	ld h,c
	push de
	ldir
	pop hl
	ret

.only_handle_vram:
	ld hl,(ti.mpLcdUpbase)
	ld (saved_LcdUpbase),hl
	ld de,LCD_VRAM
	or a,a
	sbc hl,de
	ret nz
	add hl,de
	ld de,LCD_BUFFER
	ld bc,LCD_WIDTH*LCD_HEIGHT
	push hl,de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de
	pop de
    ret

