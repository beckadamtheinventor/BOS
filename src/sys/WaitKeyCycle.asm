;@DOES Wait until a key is pressed, then wait until it's released, then return the keycode
;@OUTPUT A = keycode
;@DESTROYS HL,DE,BC,AF
sys_WaitKeyCycle:
	call sys_HandleOnInterrupt
	HandleNextThread_IfOSThreading
	call sys_GetKey
	or a,a
	jr z,sys_WaitKeyCycle
if $ <> sys_WaitKeyUnpress
	jq sys_WaitKeyUnpress
end if