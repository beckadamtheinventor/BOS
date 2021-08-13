;@DOES Check how much memory is free in Malloc RAM
;@INPUT int sys_CheckMallocRAM(void);
;@DESTROYS All
sys_CheckMallocRAM:
	ld de,malloc_cache
	ld bc,4096
	xor a,a
	sbc hl,hl
.loop:
	ex hl,de
	cpi
	jq nz,.nonzero
	inc de
.nonzero:
	ex hl,de
	jp pe,.loop
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ret
