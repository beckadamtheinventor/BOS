;@DOES Ensure that the display is not cleared when returning from this program.
;@INPUT None
;@OUTPUT None
;@DESTROYS None
;@NOTE By default, the display will be cleared when exiting a user program. This routine ensures it does not.
sys_ReturnFromNonFullscreen:
	push hl
	ld hl,(return_code_flags)
	res bReturnFromFullScreen, (hl)
	pop hl
	ret
