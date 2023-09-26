
; /dev/lcd device type memory, r/w + DMA r/w + Init + Deinit, version 2, handling no interrupts.
device_file devtMemory, mDeviceReadable or mDeviceWritable or mDeviceHasDMA or mDeviceDMAReadable or mDeviceDMAWritable or mDeviceInit or mDeviceDeinit, 2, deviceIntNone
	export device_JumpInit,   dev_lcd_init
	export device_JumpDeinit, dev_lcd_deinit
	export device_JumpGetDMA, dev_lcd_get_address
	export device_JumpRead,   dev_lcd_read
	export device_JumpWrite,  dev_lcd_write
dev_lcd_write:
	call dev_lcd_compute
	ex hl,de
	jr dev_lcd_read.copy
dev_lcd_read:
	call dev_lcd_compute
.copy:
	ldir
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
if ~ti.vRam and $FF
	ld (hl),l
else
	ld (hl),0
end if
	ld bc,320*240*2-1
	ldir
	ret
dev_lcd_compute:
	push iy
	ld iy,3
	add iy,sp
	ld l,(iy+9)
	ld h,160
	mlt hl
	add hl,hl
	ld de,(iy+6)
	add hl,de
	ld de,ti.vRam
	add hl,de
	ld de,(iy+12)
	ld bc,(iy+15)
	pop iy
	ret

end device_file
