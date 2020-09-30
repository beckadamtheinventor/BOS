usb_ClearEndpointHalt:
	call	_Error.check
	ld	yendpoint,(ix+6)
	ld	hl,(yendpoint.first)
	bitmsk	transfer.next.dummy,(hl+transfer.next)
	jq	z,_Error.NOT_SUPPORTED
	call	_Alloc32Align32
	jq	nz,_Error.NO_MEMORY
	call	usb_GetEndpointAddress.enter
	inc	de;0
	push	hl,de
	ld	e,DEFAULT_RETRIES
	push	de,hl,hl
assert ~ENDPOINT_HALT
iterate value, HOST_TO_DEVICE or STANDARD_REQUEST or RECIPIENT_ENDPOINT, CLEAR_FEATURE, d, d, a, d, d, d
	ld	(hl),value
 if % <> %%
	inc	l
 end if
end iterate
	xor	a,a
	ld	hl,(yendpoint.device+1)
	call	usb_GetDeviceEndpoint.enter
	push	hl
	call	usb_ControlTransfer
	ld	yendpoint,(ix+6)
	ex	de,hl
	ld	hl,(ix-6)
	call	_Free32Align32
	ex	de,hl
	resmsk	yendpoint.overlay.remaining.dt
	jq	usb_Transfer.return

