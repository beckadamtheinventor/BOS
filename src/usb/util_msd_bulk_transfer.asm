; inputs:
;   a : bulk endpoint address
;  bc : packet len
;  ix : data buffer
util_msd_bulk_transfer:
	push	iy
	or	a,a
	sbc	hl,hl
	push	hl
	push	hl			; zero retries (handled by states)
	push	bc
	push	ix			; packet to send
	ld	l,a
	push	hl
	ld	bc,(ymsdDevice.dev)
	push	bc
	call	usb_GetDeviceEndpoint
	pop	bc,bc
	push	hl
	call	usb_Transfer
	pop	bc,bc,bc,bc,bc
	pop	iy
	compare_hl_zero
	ret

