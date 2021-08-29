;@DOES Wait until a key is pressed and return it
;@DESTROYS HL,DE,BC,AF
sys_WaitKey:
	HandleNextThread_IfOSThreading
	call kb_AnyKey
	jr z,sys_WaitKey
	jq sys_GetKey

