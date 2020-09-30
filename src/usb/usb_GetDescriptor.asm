usb_GetDescriptor:
	call	_Error.check
	ld	c,GET_DESCRIPTOR
	ld	de,(ix+21)
	call	_Alloc32Align32
	ld	(hl),DEVICE_TO_HOST or STANDARD_REQUEST or RECIPIENT_DEVICE
.enter:
	jq	nz,_Error.NO_MEMORY
	push	hl,de
	ld	de,DEFAULT_RETRIES
	push	de
	ld	de,(ix+15)
	push	de,hl
	inc	l
	ld	(hl),c
	inc	l
	ld	c,(ix+12)
	ld	(hl),c
	inc	l
	ld	c,(ix+9)
	ld	(hl),c
	inc	l
	ld	(hl),a
	inc	l
	ld	(hl),a
.length:
	inc	l
	ld	de,(ix+18)
	ld	(hl),de
.endpoint:
	ld	hl,(ix+6)
	call	usb_GetDeviceEndpoint.enter
	push	hl
	call	usb_ControlTransfer
	ex	de,hl
	ld	hl,(ix-6)
	call	_Free32Align32
	ex	de,hl
.return:
	jq	usb_Transfer.return
