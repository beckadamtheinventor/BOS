;@DOES Check if there are HL bytes avalible in userMem
_EnoughMem:
	ex hl,de
	ld hl,(remaining_free_RAM)
	or a,a
	sbc hl,de
	ex hl,de
	ret
