util_msd_xfer_cbw:
	ld	iy,(util_scsi_request.msdstruct)
	ld	a,hl,(ymsdDevice.tag)
	ld	ix,0
.cbw := $-3
	ld	(xpacketCBW.tag),a,hl
	ld	bc,1
	add	hl,bc
	adc	a,b
	ld	(ymsdDevice.tag),a,hl	; increment the tag
	ld	bc,sizeof packetCBW
	ld	a,(ymsdDevice.bulkoutaddr)
	call	util_msd_bulk_transfer
	ret	z			; check the command was accepted
.retry:
	call	util_msd_reset_recovery
	jq	util_msd_xfer_cbw