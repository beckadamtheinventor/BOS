;@DOES Wait until a key is pressed and return it
;@DESTROYS HL,DE,BC,AF
sys_WaitKey:
	call sys_HandleOnInterrupt
	HandleNextThread_IfOSThreading
	call kb_AnyKey
	jr z,sys_WaitKey
if $ <> sys_GetKey
	jq sys_GetKey
end if
