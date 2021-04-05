;@DOES divide by 512, adding 1 to the result if there is a remainder. Returns 1 if HL is 0
;@INPUT HL = number to divide
;@OUTPUT HL = result
fs_CeilDivBySector:
	ld bc,512
	call ti._idvrmu
	ld a,e
	or a,d
	jq z,.return1
	ld a,l
	or a,h
	ex hl,de
	ret z
	inc hl
	ret
.return1:
	ex hl,de
	inc hl
	ret
