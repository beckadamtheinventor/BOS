
_ChkBCIs0:
	push bc
	db $3E
_ChkDEIs0:
	push de
	db $3E
_ChkHLIs0:
	push hl
.entry:
	inc sp
	pop af
	dec sp
	or a,l
	or a,h
	ret

