util_msd_xfer_data:
	ld	bc,(xpacketCBW.len)
	sbc	hl,hl
	adc	hl,bc
	ret	z			; no transfer if 0 len
	ld	a,(xpacketCBW.dir)	; check direction
	ld	iy,(util_scsi_request.msdstruct)
	ld	ix,0
.data := $ - 3
	or	a,a
	ld	a,(ymsdDevice.bulkinaddr)
	jr	nz,.xfer
	ld	a,(ymsdDevice.bulkoutaddr)
.xfer:
	call	util_msd_bulk_transfer
	ret	z
	call	util_msd_xfer_cbw.retry
	jq	util_msd_xfer_data

