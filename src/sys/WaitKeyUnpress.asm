;@DOES Wait until the last pressed keycode changes.
;@INPUT None
;@OUTPUT None
;@DESTROYS BC, DE, HL
sys_WaitKeyUnpress:
	ld a,(last_keypress)
	ld c,a
.loop:
	push bc
	HandleNextThread_IfOSThreading
	call sys_GetKey
	pop bc
	cp a,c
	jr z,.loop
	ld a,c
	or a,a
	ret
