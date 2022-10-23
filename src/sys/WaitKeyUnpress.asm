;@DOES Wait until no keys are pressed.
;@INPUT None
;@OUTPUT None
;@DESTROYS BC, DE, HL
sys_WaitKeyUnpress:
	push af
.loop:
	HandleNextThread_IfOSThreading
	call kb_AnyKey
	jr nz,.loop
	pop af
	ret
