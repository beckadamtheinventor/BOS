
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
	ld bc,$0E ;get number of reserved sectors
	add hl,bc
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
	ret
