
;@DOES return root directory descriptor for a given drive letter
;@INPUT A = Partition label / drive letter
;@OUTPUT hl = root directory descriptor
;@OUTPUT Cf is set if label/letter is invalid, or if drive is broken or invalid.
fs_RootDir:
	call fs_DataSection
	ret c
	push hl
	ld hl,$2C
	add hl,de
	ld hl,(hl)
	dec hl
	dec hl
	ld b,10
.mult_loop:
	add hl,hl
	djnz .mult_loop
	pop bc
	add hl,bc
	ld bc,$40
	add hl,bc
	ret
