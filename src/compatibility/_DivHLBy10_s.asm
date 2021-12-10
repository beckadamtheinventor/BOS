
_DivHLByA_s:
	push bc
	ld c,a
	jr _DivHLBy10_s.div
_DivHLBy10_s:
	push bc
	ld c,10
.div:
	ld b,0
	call ti._sdivu
	pop bc
	ret
