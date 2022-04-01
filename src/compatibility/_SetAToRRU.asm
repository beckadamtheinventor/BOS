
_SetAToBCU:
	push bc
	db $3E
_SetAToDEU:
	push de
	db $3E
_SetAToHLU:
	push hl
	inc sp
	pop af
	dec sp
	ret
