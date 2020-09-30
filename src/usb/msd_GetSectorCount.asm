;-------------------------------------------------------------------------------
; Gets the sector count of the device.
; args:
;  sp + 3  : msd device structure
;  sp + 6  : pointer to store sector count to
; return:
;  hl = error status
msd_GetSectorCount:
	ld	iy,0
	add	iy,sp
	ld	hl,(iy + 3)
	compare_hl_zero
	jr	z,.paramerror
	ld	hl,(iy + 6)
	compare_hl_zero
	jr	z,.paramerror
	push	iy
	ld	iy,(iy + 3)
	ld	hl,scsi.readcapacity
	lea	de,ymsdDevice.lba
	push	de
	call	util_scsi_request	; store the logical block address / size
	pop	hl
	pop	iy
	jr	nz,.error
	ld	de,(iy + 6)
	ld	bc,4
	ldir
	or	a,a
	sbc	hl,hl
	ret
.paramerror:
	ld	hl,MSD_ERROR_INVALID_PARAM
	ret
.error:
	ld	hl,MSD_ERROR_USB_FAILED
	ret
