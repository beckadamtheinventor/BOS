;@DOES Check if there are HL bytes avalible in userMem
_EnoughMem:
	ld de,(remaining_free_RAM)
	or a,a
	sbc hl,de
	add hl,de
	ccf
	ret
