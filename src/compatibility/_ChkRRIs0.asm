
_ChkHLIs0:
	call _SetAToHLU
	or a,l
	or a,h
	ret

_ChkDEIs0:
	call _SetAToDEU
	or a,e
	or a,d
	ret

_ChkBCIs0:
	call _SetAToBCU
	or a,c
	or a,b
	ret

	

