;@DOES Get the current keypress and return it in A
_GetCSC:
	call sys_GetKey
	push af
	ld a,7
	call ti.DelayTenTimesAms
	pop af
	or a,a
	sbc hl,hl
	ld l,a
	ret
