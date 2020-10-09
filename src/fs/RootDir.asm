
;@DOES return root directory data pointer for a given drive letter
;@INPUT A = Partition label / drive letter
;@OUTPUT hl = root directory data pointer
;@OUTPUT de = Volume ID sector
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
	ld b,9 ;multiply by sector size
.mult_loop:
	add hl,hl
	djnz .mult_loop
	call fs_MultBySectorsPerCluster ;multiply by sectors per cluster
	pop bc
	add hl,bc
	ld bc,$40
	add hl,bc
	or a,a
	ret
