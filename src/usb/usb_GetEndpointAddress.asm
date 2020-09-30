usb_GetEndpointAddress:
	pop	hl
	ex	(sp),yendpoint
	push	hl
.enter:
	ld	de,-1
	add	yendpoint,de
	ld	a,e
	ret	nc
	ld	a,(yendpoint.dir+1)
	rrca
	ld	a,(yendpoint.info+1)
	rla
	rrca
	and	a,$8F
	ret
