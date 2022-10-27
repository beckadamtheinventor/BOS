;@DOES Display a data type error message
_ErrDataType:
	ld hl,str_ErrorDataType
	jr _ShowErrorMessage
