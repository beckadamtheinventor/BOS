util_scsi_init:
	ld	hl,scsi.inquiry
	call	util_scsi_request_default
	jr	nz,.error
.unitattention:
	ld	hl,scsi.testunitready
	call	util_scsi_request_default
	jr	nz,.error
	and	a,$f
	cp	a,6
	jr	z,.unitattention
	ld	hl,scsi.readcapacity
	lea	de,ymsdDevice.lba
	call	util_scsi_request	; store the logical block address / size
	jr	nz,.error
	ld	hl,scsi.testunitready
	call	util_scsi_request_default
	jr	nz,.error
	or	a,a
	sbc	hl,hl
	ret
.error:
	ld	hl,MSD_ERROR_USB_FAILED
	ret
