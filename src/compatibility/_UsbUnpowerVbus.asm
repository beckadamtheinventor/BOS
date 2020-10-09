
;@DOES I honestly don't know. Included for compatibility with USBDRVCE.
_UsbUnpowerVbus:
	push ix,iy
	call $3C4
	ld iy, $000001
	push iy
	call $0003BC
	pop iy,iy,ix
	ret 