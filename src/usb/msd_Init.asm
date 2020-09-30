;-------------------------------------------------------------------------------
; Initialize a USB connected Mass Storage Device.
; args:
;  sp + 3  : msd device structure
;  sp + 6  : usb device to initialize as msd
;  sp + 9  : internal user-supplied buffer
; return:
;  hl = error status
msd_Init:
	ld	iy,0
	add	iy,sp
	push	ix
	ld	ix,(iy + 3)
	res	MSD_FLAG_IS_INIT,(xmsdDevice.flags)
	pop	ix
	ld	hl,(iy + 6)		; usb device
	compare_hl_zero
	jq	z,.paramerror
	push	iy
	ld	bc,tmp.length		; storage for size of descriptor
	push	bc
	ld	bc,18			; size of device descriptor
	push	bc
	ld	bc,tmp.descriptor	; storage for descriptor
	push	bc
	ld	bc,0
	push	bc
	inc	bc			; USB_DEVICE_DESCRIPTOR = 1
	push	bc
	push	hl
	call	usb_GetDescriptor
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	iy
	compare_hl_zero
	ret	nz			; return if error
	ld	de,18
	ld	hl,(tmp.length)
	compare_hl_de			; ensure enough bytes were fetched
	jq	nz,.msddeverror
	xor	a,a
	ld	(.configindex),a	; set starting index
	jq	.getconfigcheck
.getconfiguration:			; bc = index
	push	iy
	ld	c,0
.configindex := $ - 1
	push	bc
	ld	bc,(iy + 6)		; usb device
	push	bc
	call	usb_GetConfigurationDescriptorTotalLength
	pop	bc
	pop	bc
	pop	iy
	push	iy
	ld	bc,tmp.length		; storage for length of descriptor
	push	bc
	push	hl			; length of configuration descriptor
	ld	bc,(iy + 9)		; storage for configuration descriptor
	push	bc
	ld	hl,.configindex
	ld	c,(hl)
	push	bc			; configuration index
	inc	(hl)
	ld	bc,2			; USB_CONFIGURATION_DESCRIPTOR
	push	bc
	ld	bc,(iy + 6)		; usb device
	push	bc
	call	usb_GetDescriptor
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	bc
	pop	iy
	compare_hl_zero
	ret	nz			; ensure success

	; parse the configuration here for interfaces / endpoints for msd
	; we want to just grab the first bulk endpoints and msd interface

	xor	a,a
	ld	(.interfacenumber),a
	ld	(.bulkinaddr),a
	ld	(.bulkoutaddr),a
	ld	hl,(tmp.length)
	ld	(.configlengthend),hl
	ld	hl,(iy + 9)
	ld	(.configptr),hl
	push	iy
.parseinterfaces:
	ld	hl,(.configlengthend)
	ld	de,2			; check for end of configuration
	compare_hl_de
	jq	c,.parsedone		; todo: check if bLength > remaining?
	ld	iy,(.configptr)
	ld	a,(ydescriptor.bDescriptorType)
	cp	a,INTERFACE_DESCRIPTOR
	jq	z,.parseinterface
	cp	a,ENDPOINT_DESCRIPTOR
	jq	z,.parseendpoint
	jq	.parsenext
.parseinterface:
	ld	a,(yinterfaceDescriptor.bInterfaceClass)
	cp	a,$08
	jr	nz,.parsenext
	ld	a,(yinterfaceDescriptor.bInterfaceSubClass)
	cp	a,$06
	jr	nz,.parsenext
	ld	a,(yinterfaceDescriptor.bInterfaceProtocol)
	cp	a,$50
	jr	nz,.parsenext
	ld	a,(yinterfaceDescriptor.bInterfaceNumber)
	inc	a
	ld	(.interfacenumber),a
	jq	.parsenext
.parseendpoint:
	ld	a,0			; mark as valid
.interfacenumber := $ - 1
	or	a,a
	jq	z,.parsenext
	ld	a,(yendpointDescriptor.bmAttributes)
	cp	a,BULK_TRANSFER
	jq	nz,.parsenext
	ld	a,(yendpointDescriptor.bEndpointAddress)
	ld	b,a
	and	a,DEVICE_TO_HOST
	ld	a,b
	jr	z,.parseoutendpointout
.parseoutendpointin:
	ld	(.bulkinaddr),a
	jq	.parsenext
.parseoutendpointout:
	ld	(.bulkoutaddr),a
.parsenext:
	ld	de,0
	ld	e,(ydescriptor.bLength)
	ld	hl,0
.configlengthend := $ - 3
	or	a,a
	sbc	hl,de
	ld	(.configlengthend),hl
	jq	z,.parsedone
	ld	hl,0
.configptr := $ - 3
	add	hl,de
	ld	(.configptr),hl		; move to next interface
	jq	.parseinterfaces

.parsedone:
	pop	iy
	ld	a,0
.bulkinaddr := $ - 1
	or	a,a
	jq	z,.getconfigcheck	; no endpoints for msd, keep parsing
	ld	a,0
.bulkoutaddr := $ - 1
	or	a,a
	jq	z,.getconfigcheck	; no endpoints for msd, keep parsing

	ld	de,(iy + 9)
	ld	bc,(iy + 6)
	ld	iy,(iy + 3)		; setup msd structure with endpoints and buffer
	ld	(ymsdDevice.buffer),de
	ld	(ymsdDevice.dev),bc
	ld	a,(.bulkoutaddr)
	ld	(ymsdDevice.bulkoutaddr),a
	ld	a,(.bulkinaddr)
	ld	(ymsdDevice.bulkinaddr),a
	ld	a,(.configindex)
	dec	a
	ld	(ymsdDevice.configindex),a
	ld	a,(.interfacenumber)
	dec	a
	ld	(ymsdDevice.interface),a

	; successfully found bulk endpoints for msd
	; now reset the device

	call	msd_Reset.enter
	compare_hl_zero
	ret	nz
	set	MSD_FLAG_IS_INIT,(ymsdDevice.flags)
	or	a,a
	sbc	hl,hl
	ret

.getconfigcheck:
	ld	hl,tmp.descriptor + 17
	ld	a,(.configindex)
	cp	a,(hl)
	jq	nz,.getconfiguration
.msddeverror:
	ld	hl,MSD_ERROR_INVALID_DEVICE
	ret
.usberror:
	ld	hl,MSD_ERROR_USB_FAILED
	ret
.paramerror:
	ld	hl,MSD_ERROR_INVALID_PARAM
	ret






