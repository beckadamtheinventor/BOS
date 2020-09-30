usb_GetDeviceEndpoint:
	pop	de,hl,bc
	push	bc,hl,de
	inc	l
	dec	l
	ret	z
	ld	a,c
	and	a,$8F
.enter:
	ld	hl,(hl+device.endpoints)
	bit	0,hl
	jq	nz,.returnCarry
	rlca
	or	a,l
	ld	l,a
	ld	h,(hl)
	ld	l,endpoint
	ld	a,h
	inc	a
	ret	nz
.returnCarry:
	sbc	hl,hl
	ret
