
;@DOES return a pointer to the data section of a given drive letter
;@INPUT a = drive letter
;@OUTPUT hl = drive data section. hl = -1 if failed.
;@OUTPUT de = Volume ID sector
;@OUTPUT Cf is set if failed.
fs_DataSection:
	call fs_ClusterMap
	jq c,.fail
	push de,hl
	ld hl,$24
	add hl,de
	ld hl,(hl)
	ld b,10 ;two sets of sectors
.mult_loop:
	add hl,hl
	djnz .mult_loop
	pop bc,de
	add hl,bc ; add cluster tables
	or a,a
	ret
.fail:
	scf
	sbc hl,hl
	ret

