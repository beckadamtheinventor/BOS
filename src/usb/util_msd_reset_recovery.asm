;  hopefully recovers transfer state
util_msd_reset_recovery:
	ld	iy,(util_scsi_request.msdstruct)
	call	util_msd_reset
	compare_hl_zero
	jr	z,.resetsuccess
.fatalerror:
	ld	sp,0
.errorsp := $ - 3
	pop	ix
	xor	a,a
	inc	a
	ret
.resetsuccess:
	ld	iy,(util_scsi_request.msdstruct)
	ld	a,(ymsdDevice.bulkinaddr)
	call	util_ep_stall
	ld	a,(ymsdDevice.bulkoutaddr)
util_ep_stall:
	push	iy
	or	a,a
	sbc	hl,hl
	ld	l,a
	push	hl
	ld	bc,(ymsdDevice.dev)
	push	bc
	call	usb_GetDeviceEndpoint
	compare_hl_zero
	jq	z,util_msd_reset_recovery.fatalerror
	pop	bc
	pop	bc
	push	hl
	call	usb_ClearEndpointHalt
	pop	bc
	pop	iy
	ret

