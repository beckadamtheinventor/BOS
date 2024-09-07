;@DOES Return a random 32-bit number.
;@INPUT uint32_t sys_Random32();
;@OUTPUT EUHL = number
;@DESTROYS AF, DE, HL, BC
sys_Random32:
	ld c,3
	ld de,ti.scrapMem
.loop:
	call sys_Random8
	ld (de),a
	inc de
	dec c
	jr nz,.loop
	call sys_Random8
	ld hl,(ti.scrapMem)
	ld e,a
	ret
