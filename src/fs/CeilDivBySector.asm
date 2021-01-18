;@DOES divide by 512, adding 1 to the result if there is a remainder.
;@INPUT HL = number to divide
;@OUTPUT HL = result
fs_CeilDivBySector:
	ld bc,512
	call ti._idvrmu
	ld a,l
	or a,h
	ex hl,de
	ret z
	inc hl
	ret

