;-------------------------------------------------------------------------------
; Input:
;  a = alt
;  b = num interfaces
;  de = length or ? shl 16
;  ix = descriptors
;  iy = device
; Output:
;  zf = valid
;  a = 0 | ?
;  bc = ?
;  de = ? and $FFFF
;  hl = ? and $FFFF
;  ix = ?
;  iy = device
_ParseInterfaceDescriptors:
	ld	hl,mpUsbDevTest
	set	bUsbTstClrFifo,(hl)
	res	bUsbTstClrFifo,(hl)
.host:
	inc	b
.dec:
	ld	(.alt),a
	or	a,a
	sbc	hl,hl
	ex.s	de,hl
	ld	c,e
	jq	.enter
.endpoint:
	cp	a,c
	jq	z,.next
	ld	a,e
	cp	a,sizeof xendpointDescriptor
	ret	c
	push	bc,de,hl,ydevice
	lea	de,xendpointDescriptor
	call	_CreateEndpoint
	pop	ydevice,hl,de,bc
	ret	nz
	dec	c
.next:
	add	xdescriptor,de
.enter:
	add	hl,de
	xor	a,a
	sbc	hl,de
	ret	z
	ld	a,(xdescriptor.bLength)
	cp	a,sizeof xdescriptor
	ret	c
	ld	e,a
	sbc	hl,de
	ret	c
	ld	a,(xdescriptor.bDescriptorType)
	sub	a,ENDPOINT_DESCRIPTOR
	jq	z,.endpoint
repeat ENDPOINT_DESCRIPTOR-INTERFACE_DESCRIPTOR
	inc	a
end repeat
	jq	nz,.next
	ld	c,a
	ld	a,e
	cp	a,sizeof xinterfaceDescriptor
	ret	c
	ld	a,(xinterfaceDescriptor.bAlternateSetting)
	sub	a,0
label .alt at $-byte
	jq	nz,.next
	ld	c,(xinterfaceDescriptor.bNumEndpoints)
	djnz	.next
	ret