; inputs:
;  iy : msd structure
;  hl : packet
;  de : location to store data to
util_msd_ctl_packet:
	push	iy
	ld	bc,0
	push	bc			; don't care about transfer size
	ld	bc,DEFAULT_RETRIES
	push	bc			; retry as needed
	push	de			; send data packet
	push	hl			; send setup packet
	ld	bc,0
	push	bc
	ld	bc,(ymsdDevice.dev)
	push	bc
	call	usb_GetDeviceEndpoint
	pop	bc
	pop	bc
	push	hl
	call	usb_ControlTransfer
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	iy
	ret
