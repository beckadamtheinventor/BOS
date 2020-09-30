util_msd_read_write_sectors:
	ld	iy,3
	add	iy,sp
	lea	hl,iy + 6
	lea	de,xscsipktrw.lba + 3
	ld	a,(hl)
	ld	(de),a
	inc	hl
	dec	de
	ld	a,(hl)
	ld	(de),a
	inc	hl
	dec	de
	ld	a,(hl)
	ld	(de),a
	inc	hl
	dec	de
	ld	a,(hl)
	ld	(de),a
	lea	hl,xscsipktrw.len
	ld	de,(iy + 12)
	ld	(hl),d
	inc	hl
	ld	(hl),e
	ex	de,hl
	add	hl,hl
	ld	(xscsipktrw + 9),hl
	ld	de,(iy + 15)
	ld	iy,(iy + 3)
	lea	hl,xscsipktrw
	call	util_scsi_request
	pop	ix
	ld	hl,MSD_ERROR_USB_FAILED
	ret	nz
	or	a,a
	sbc	hl,hl			; return success
	ret

