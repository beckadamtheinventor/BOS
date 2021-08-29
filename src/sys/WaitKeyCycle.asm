;@DOES Wait until a key is pressed, then wait until it's released, then return the keycode
;@OUTPUT A = keycode
;@DESTROYS HL,DE,BC,AF
sys_WaitKeyCycle:
	call sys_GetKey
	or a,a
	jr z,sys_WaitKeyCycle
	push af
.loop:
	HandleNextThread_IfOSThreading
	call kb_AnyKey
	jr nz,.loop
	pop af
	ret

