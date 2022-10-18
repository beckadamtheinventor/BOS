;@DOES Display a memory error message
_ErrMemory:
	ld hl,str_ErrorMemory
	call gui_DrawConsoleWindow
	jq sys_WaitKeyCycle
