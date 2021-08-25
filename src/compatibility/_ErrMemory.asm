;@DOES Quit the program and display a memory error message
_ErrMemory:
	ld hl,.string
	call gui_DrawConsoleWindow
	jp os_return
.string:
	db $9,"Error: Not Enough Memory!",$A,0
