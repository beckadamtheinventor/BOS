;@DOES compare HL to DE. Returns the resultant of "sbc hl,de" without modifying either.
_CpHLDE:
	or a,a
	sbc hl,de
	add hl,de
	ret
