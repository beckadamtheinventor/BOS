;@DOES Wait until the last pressed keycode changes or there is no key pressed.
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
    or a,a
    jr z,.done
	cp a,c
	jr z,.loop
.done:
	ld a,c
	or a,a
	ret
