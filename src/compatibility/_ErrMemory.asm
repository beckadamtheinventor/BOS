;@DOES Display a memory error message
_ErrMemory:
	ld hl,str_ErrorMemory
	jr _ShowErrorMessage
