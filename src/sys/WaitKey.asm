;@DOES Wait until a key is pressed and return it
;@DESTROYS HL,DE,BC,AF
sys_WaitKey:
	call kb_AnyKey
	jr z,sys_WaitKey
	jp sys_GetKey

