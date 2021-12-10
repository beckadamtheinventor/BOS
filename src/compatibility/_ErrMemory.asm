;@DOES Display a memory error message
_ErrMemory:
	ld hl,.string
	call gui_DrawConsoleWindow
	jq sys_WaitKeyCycle
.string:
	db $9,"Error: Not Enough Memory!",$A,0
