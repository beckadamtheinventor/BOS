usb_Transfer:
	ld	hl,usb_ScheduleTransfer.enter
.enter:
	ld	(.dispatch),hl
	call	_Error.check
	ld	hl,(ix+15)
	push	hl
	ld	hl,(ix+18)
	push	hl
	sbc	hl,hl
	inc	l
	push	hl
	ld	hl,.callback
	ld	(ix+15),hl
	ld	(ix+18),ix
	call	0
label .dispatch at $-long
.wait:
	push	bc
	call	usb_WaitForEvents
	pop	bc
	add	hl,de
	or	a,a
	sbc	hl,de
	jq	nz,.return
	ld	l,(ix-12)
	dec	l
	jq	z,.wait
	inc	l
.return:
	ld	sp,ix
	pop	ix
	ret

.callback:
	ld	hl,12
	add	hl,sp
	ld	iy,(hl)
repeat long
	dec	hl
end repeat
	ld	bc,(hl)
repeat long
	dec	hl
end repeat
	ld	a,(hl)
	sbc	hl,hl
	or	a,a;USB_TRANSFER_COMPLETED
	jq	z,.complete
	and	a,USB_TRANSFER_CANCELLED or USB_TRANSFER_OVERFLOW or USB_TRANSFER_NO_DEVICE or USB_TRANSFER_STALLED
	ld	a,USB_ERROR_FAILED
	jq	nz,.complete
	ld	de,(iy-6)
	inc	l
	add	hl,de
	inc	l
	ret	c
	sbc	hl,hl
	dec	hl
	adc	hl,de
	ld	(iy-6),hl
	ld	hl,1
	ret	nz
assert USB_ERROR_TIMEOUT = USB_ERROR_FAILED-1
	dec	a;USB_ERROR_TIMEOUT
	dec	hl
	or	a,a
.complete:
	ld	(iy-12),a
	ld	de,(iy-9)
	adc	hl,de
	ret	z
	ld	(hl),bc
	sbc	hl,hl
	ret
