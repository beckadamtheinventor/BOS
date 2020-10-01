;@DOES Quit the program and display a memory error message
_ErrMemory:
	ld hl,(SaveSP)
	ld sp,hl
	ld hl,.string
	jp gui_DrawConsoleWindow
.string:
	db $9,"Error: Not Enough Memory!",$A,0
