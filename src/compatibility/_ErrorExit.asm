;@DOES Display a generic error message and soft reboot.
_ErrorExit:
	scf
	sbc hl,hl
	assert $ = _ShowErrorMessage
