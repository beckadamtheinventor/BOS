;@DOES Clear the screen and display the current working directory.
_DrawStatusBar:
	ld hl,current_working_dir
	jq gui_DrawConsoleWindow
