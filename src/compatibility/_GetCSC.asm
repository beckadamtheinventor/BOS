;@DOES Get the current keypress and return it in A
_GetCSC:
	call sys_GetKey
	ld hl,ti.kbdScanCode
	ret
