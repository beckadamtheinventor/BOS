;@DOES multiply by number of sectors per cluster
fs_MultBySectorsPerCluster:
	push de
	ex hl,de
	or a,a
	sbc hl,hl
	ld a,(current_sectors_per_cluster)
	ld b,a
.loop:
	add hl,de
	djnz .loop
	pop de
	ret
