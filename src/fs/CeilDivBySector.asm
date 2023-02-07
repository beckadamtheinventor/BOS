;@DOES divide by sector size, adding 1 to the result if there is a remainder. Returns 1 if HL is 0
;@INPUT HL = number to divide
;@OUTPUT HL = result
fs_CeilDivBySector:
	ld c,fs_sector_size_bits
	ld a,l
	and a,fs_sector_size-1
	push af
	call ti._ishru
	ex.s hl,de
	ex hl,de
	pop af
	ret z
	inc hl
	ret
