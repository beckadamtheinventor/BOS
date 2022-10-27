;@DOES Display an unimplemented feature error message
_ErrUnimplemented:
	ld hl,str_ErrorUnimplemented
	jr _ShowErrorMessage
