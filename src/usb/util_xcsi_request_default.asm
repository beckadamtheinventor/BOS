; input:
;  hl : ptr to scsi command
;  de : ptr to storage (non-default)
;  iy : ptr to msd structure
; output;
;   z : success
;  nz : failure
util_scsi_request_default:
	ld	de,(ymsdDevice.buffer)
util_scsi_request:
	push	ix
	ld	(.msdstruct),iy
	xor	a,a
	ld	(tmp.sensecount),a
	ld	(util_msd_reset_recovery.errorsp),sp
	ld	(util_msd_xfer_cbw.cbw),hl
	ld	(util_msd_xfer_data.data),de
.resendcbw:
	call	util_msd_xfer_cbw
	call	util_msd_xfer_data
	call	util_msd_xfer_csw
	pop	ix
	ld	iy,0
.msdstruct = $-3
	ret

