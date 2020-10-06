
;@DOES return a pointer to a given drive's first cluster map.
;@INPUT a = drive letter
;@OUTPUT hl = cluster map
;@OUTPUT de = Volume ID sector
;@OUTPUT Cf is set if failed.
fs_ClusterMap:
	call fs_PartitionDescriptor
	ret c
	inc hl
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	cp a,$0B ;check filesystem type is 0x0B or 0x0C
	ret c
	cp a,$0D
	ccf
	ret c
	inc hl
	inc hl
	inc hl
	inc hl
	ld hl,(hl) ;LBA of partition
	ld b,9
.multloop:
	add hl,hl
	djnz .multloop ;address of partition
	push hl
	;get number of sectors per cluster
	ld bc,$0D
	add hl,bc
	ld a,(hl)
	ld (current_sectors_per_cluster),a
	;get number of reserved sectors
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex.s hl,de
	ld b,9
.multloop2:
	add hl,hl
	djnz .multloop2 ;get number of bytes in reserved sectors
	pop de
	add hl,de
	or a,a
	ret
