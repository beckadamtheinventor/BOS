
;@DOES compare HL to DE. (16 bit) Returns the resultant of "sbc.s hl,de" without modifying either.
_CpHLDE_s:
	or a,a
	sbc.s hl,de
	add.s hl,de
	ret

;@DOES compare HL to DE. Returns the resultant of "sbc hl,de" without modifying either.
_CpHLDE:
	or a,a
	sbc hl,de
	add hl,de
	ret

;@DOES return Cf if HL >= BC and HL <= DE?
_CpHLDEBC:
	or a,a
	sbc hl,bc
	add hl,bc
	jr c,.return_not_cf
	ex hl,de
	sbc hl,de
	add hl,de
	ex hl,de
.return_not_cf:
	ccf
	ret