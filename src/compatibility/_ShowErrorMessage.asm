;@DOES Show an error message and soft reboot.
;@INPUT HL = error message
_ShowErrorMessage:
	push hl
	ld hl,str_ErrorOccurred
	call gui_DrawConsoleWindow
	pop hl
	call gui_PrintLine
	call sys_WaitKeyUnpress
	call sys_WaitKeyCycle
	jq os_return
