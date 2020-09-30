;-------------------------------------------------------------------------------
; Gets the block size from the device.
; The library assumes that sector size == msd block size.
; args:
;  sp + 3  : msd device structure
;  sp + 6  : pointer to store block size to
; return:
;  hl = error status
msd_GetSectorSize:
	ld	iy,0
	add	iy,sp
	ld	hl,(iy + 3)
	compare_hl_zero
	jr	z,.paramerror
	ld	hl,(iy + 6)
	compare_hl_zero
	jr	z,.paramerror
	push	hl
	ld	iy,(iy + 3)
	ld	hl,scsi.readcapacity
	lea	de,ymsdDevice.lba
	call	util_scsi_request	; store the logical block address / size
	pop	hl
	jr	nz,.error
	ld	de,(ymsdDevice.blocksize)
	ld	(hl),de
	or	a,a
	sbc	hl,hl
	ret
.paramerror:
	ld	hl,MSD_ERROR_INVALID_PARAM
	ret
.error:
	ld	hl,MSD_ERROR_USB_FAILED
	ret

