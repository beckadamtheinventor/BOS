
;@DOES calls sys_GetCSC after a short delay
_slow_GetCSC:
	ld a,10
	call ti.DelayTenTimesAms
	jp sys_GetKey
