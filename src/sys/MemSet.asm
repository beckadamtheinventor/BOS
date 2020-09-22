;@DOES set BC bytes of HL to the value A
;@INPUT HL pointer to set
;@INPUT BC amount to set
;@INPUT A byte to set memory to
;@OUTPUT HL HL+BC
;@OUTPUT DE HL+BC+1
;@DESTROYS AF
sys_MemSet:
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ret

