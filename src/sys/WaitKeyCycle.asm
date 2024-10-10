;@DOES Wait until a key is pressed, wait until it is released or another is pressed, returning the original keycode.
;@OUTPUT A = keycode
;@DESTROYS HL,DE,BC,AF
sys_WaitKeyCycle:
	call sys_HandleOnInterrupt
	HandleNextThread_IfOSThreading
	call sys_GetKey
	; or a,a
	jr z,sys_WaitKeyCycle
if $ <> sys_WaitKeyUnpress
	jq sys_WaitKeyUnpress
end if