;@DOES get a pointer to a given drive letter
fs_DrivePtr:
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
	ret

