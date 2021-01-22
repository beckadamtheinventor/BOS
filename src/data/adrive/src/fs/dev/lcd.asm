	db $C9, 0
	jp dev_lcd_init
	jp dev_lcd_deinit
	jp dev_lcd_get_address
	jp dev_lcd_read
	jp dev_lcd_write
dev_lcd_write:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,ti.vRam
	add hl,bc
	ex hl,de
	jq dev_lcd_read.copy
dev_lcd_read:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,ti.vRam
	add hl,bc
.copy:
	ld bc,(ix+12)
	ldir
	pop ix
	ret
dev_lcd_get_address:
	ld hl,ti.vRam
	ret
dev_lcd_init:
	call dev_lcd_deinit
	ld	a,$27
	ld	($E30018),a
	ld	de,$E30200  ; address of mmio palette
	ld	b,e         ; b = 0
.loop:
	ld	a,b
	rrca
	xor	a,b
	and	a,224
	xor	a,b
	ld	(de),a
	inc	de
	ld	a,b
	rla
	rla
	rla
	ld	a,b
	rra
	ld	(de),a
	inc	de
	inc	b
	jr	nz,.loop		; loop for 256 times to fill palette
	ret
dev_lcd_deinit:
	ld hl,ti.vRam
	ld de,ti.vRam+1
	ld (hl),l
	ld bc,320*240*2-1
	ldir
	ret

