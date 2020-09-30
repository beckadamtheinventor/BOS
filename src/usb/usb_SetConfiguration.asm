usb_SetConfiguration:
	call	_Error.check
	ld	de,(ix+12)
	ld	ydevice,(ix+6)
	push	ix
	ld	xconfigurationDescriptor,(ix+9)
assert xconfigurationDescriptor.bNumInterfaces+1 = xconfigurationDescriptor.bConfigurationValue
	ld	bc,(xconfigurationDescriptor.bNumInterfaces)
	push	bc
	ld	b,c
	call	_ParseInterfaceDescriptors.host
	pop	bc,ix
	jq	nz,_Error.INVALID_PARAM
	call	_Alloc32Align32
	jq	nz,_Error.NO_MEMORY
	ld	e,d
	push	hl,de
	ld	e,DEFAULT_RETRIES
	push	de,de,hl
	ld	(hl),d;HOST_TO_DEVICE or STANDARD_REQUEST or RECIPIENT_DEVICE
	inc	l
	ld	(hl),SET_CONFIGURATION
	inc	l
	ld	(hl),b
repeat 2
	inc	l
	ld	(hl),a
end repeat
.length:
repeat 3
	inc	l
	ld	(hl),a
end repeat
	jq	usb_GetDescriptor.endpoint
