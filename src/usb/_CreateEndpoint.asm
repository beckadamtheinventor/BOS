; Input:
;  de = endpoint descriptor
;  iy = device
; Output:
;  zf = enough memory
;  iy = endpoint | ?
_CreateEndpoint:
	call	_Alloc64Align256
	ret	nz
	ld	bc,(dummyHead.next)
	ld	(hl+endpoint.next),bc
repeat endpoint.prev-endpoint
	inc	c
end repeat
	ld	a,h
	ld	(bc),a
	inc	de;endpointDescriptor.descriptor.bDescriptorType
	inc	de;endpointDescriptor.bEndpointAddress
	ld	a,(de)
	and	a,endpoint.info.ep
	or	a,(ydevice.speed)
	ld	l,endpoint
	push	af,hl
repeat endpoint.prev-endpoint
	inc	l
end repeat
	ld	(hl),dummyHead shr 8 and $FF
repeat endpoint.addr-endpoint.prev
	inc	l
end repeat
	ld	c,(ydevice.addr)
	ld	(hl),c
repeat endpoint.info-endpoint.addr
	inc	l
end repeat
	ld	(hl),a
	ld	bc,(ydevice.endpoints)
	ld	a,(de)
	and	a,$8F
	rlca
	or	a,c
	ld	c,a
	ld	a,h
	ld	(bc),a
	inc	de
	ld	a,(de)
	and	a,bmUsbFifoType
	jq	nz,.notControl
	ld	a,c
	xor	a,1
	ld	c,a
	ld	a,h
	ld	(bc),a
	setmsk	endpoint.info.dtc,(hl)
	ld	a,endpoint.maxPktLen.control shr 8
.notControl:
repeat endpoint.maxPktLen-endpoint.info
	inc	l
end repeat
	ex	de,hl
	inc	hl
	ldi
	or	a,$F0
	xor	a,(hl)
	and	a,$F8
	xor	a,(hl)
	ex	de,hl
	ld	(hl),a
	xor	a,a
	ld	bc,(ydevice.info)
iterate reg, a, a, c, b; endpoint.smask, endpoint.cmask, endpoint.hubInfo
	inc	l
	ld	(hl),reg
end iterate
	ld	l,endpoint.device
	ld	(hl),ydevice
	pop	yendpoint
assert endpoint.device and 1
	ld	(yendpoint.overlay.altNext),l
	call	_CreateDummyTransfer.enter
	pop	bc
	jq	nz,.nomem
	ld	(yendpoint.overlay.next),hl
	ld	(yendpoint.first),hl
	ld	(yendpoint.last),hl
	ex	de,hl
	ld	(yendpoint.overlay.status),a
	ld	(yendpoint.flags),a
	ld	(yendpoint.internalFlags),a
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	ld	a,e
	or	a,d
	jq	z,.checkedMps
	dec	de
	ld	a,e
	and	a,(hl)
	ld	e,a
	inc	hl
	ld	a,d
	and	a,(hl)
	or	a,e
	dec	hl
	jq	nz,.checkedMps
	setmsk	PO2_MPS,(yendpoint.internalFlags)
.checkedMps:
	dec	hl
	ld	a,(hl)
	and	a,bmUsbFifoType
	ld	(yendpoint.type),a
	or	a,bmUsbFifoEn
	ld	e,a
	dec	hl
	ld	a,(hl)
	and	a,1 shl 7
	rlca
	ld	(yendpoint.dir),a
	ld	(dummyHead.next),yendpoint
	sbc	hl,hl
	ld	a,(currentRole)
	and	a,bmUsbRole shr 16
	ret	z
	inc	b
	dec	b
assert bmUsbRole shr 16 = bmUsbDmaCxFifo
	jq	z,.control
assert bmUsbRole shr 16 = usbFifoIn
	and	a,l
	ld	c,a
	ld	hl,mpUsbFifo0Map-1
	ld	a,l
	add	a,b
	ld	l,a
	ld	a,(hl)
	and	a,not bmUsbFifoDir
	or	a,c
	ld	(hl),a
assert usbFifo0Cfg > usbFifo0Map
	setmsk	usbFifo0Cfg xor usbFifo0Map,hl
	ld	(hl),e
	ld	a,usbOutEp1+1-4-$100
assert usbOutEp1 > usbInEp1
repeat 2
	sub	a,c
end repeat
repeat 4
	add	a,b
end repeat
	ld	l,a
	ld	(hl),bmUsbEpReset shr 8
	ld	de,(yendpoint.maxPktLen)
	ld	a,d
	and	a,bmUsbEpMaxPktSz shr 8
	ld	(hl),a
	dec	l
	ld	(hl),e
	xor	a,a
	scf
.shift:
	rla
	djnz	.shift
.control:
	ld	(yendpoint.overlay.fifo),a
	ret
.nomem:
	lea	hl,yendpoint.base
	jq	_Free64Align256