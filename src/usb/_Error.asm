element error
label _Error at error

iterate error, SYSTEM, INVALID_PARAM, SCHEDULE_FULL, NO_DEVICE, NO_MEMORY, NOT_SUPPORTED, TIMEOUT, FAILED

.error:
	ld	a,USB_ERROR_#error
	jq	.return

end iterate

.check:
	pop	de
	call	__frameset0
	ld	a,(mpIntMask)
	and	a,intTmr3
	jq	nz,.SYSTEM
	ld	a,(mpUsbSts)
	and	a,bmUsbIntHostSysErr
	jq	nz,.SYSTEM
	ld	a,(usbInited)
	dec	a
	jq	nz,.SYSTEM
	ex	de,hl
	call	_DispatchEvent.dispatch
	jq	.success

.success:
	xor	a,a
	jq	.return

.return:
	or	a,a
	sbc	hl,hl
	ld	l,a
	jq	usb_Transfer.return