
;@DOES I honestly don't know. Included this routine for compatibility with USBDDRVCE.
_UsbPowerVbus:
	push ix,iy
	call $3C0
	call $3C8
	pop iy,ix
	ret

