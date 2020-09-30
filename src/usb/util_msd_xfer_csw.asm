util_msd_xfer_csw:
	ld	iy,(util_scsi_request.msdstruct)
	call	util_msd_status_xfer
	jr	z,.checkcsw
	call	util_msd_status_xfer	; attempt to read csw again
	jr	z,.checkcsw
.retry:
	call	util_msd_xfer_cbw.retry
	call	util_msd_xfer_data
	jq	util_msd_xfer_csw
.checkcsw:
	ld	a,(tmp.csw.status)
	or	a,a			; check for good status of transfer
	jr	nz,.invalid
.valid:
	ld	a,hl,(tmp.csw.residue)
	add	hl,de
	or	a,a
	ld	a,16
	ret	nz
	sbc	hl,de
	ret	nz			; if residue != 0, retry transfer
	xor	a,a			; return success
	ret
.invalid:
	dec	a			; check for sense error (we can recover)
	jr	nz,.retry		; handle command fail (phase error)
.senseerror:
	ld	hl,tmp.sensecount
	or	a,(hl)
	ret	nz
	inc	(hl)
	ld	de,tmp.sensebuffer
	ld	hl,scsi.requestsense
	ld	(util_msd_xfer_cbw.cbw),hl
	ld	(util_msd_xfer_data.data),de
.senseresendcbw:
	call	util_msd_xfer_cbw
	call	util_msd_xfer_data
	call	util_msd_xfer_csw
	xor	a,a
	ld	(tmp.sensebuffer),a
	ld	a,(tmp.sensebuffer + 2)
	ret

