
;@DOES return root directory descriptor for a given drive letter
;@INPUT A = Partition label / drive letter
;@OUTPUT hl = root directory descriptor
;@OUTPUT Cf is set if label/letter is invalid, or if drive is broken or invalid.
fs_RootDir:
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
	ld hl,(hl) ;LBA of volume ID sector
	ld b,9
.multloop:
	add hl,hl
	djnz .multloop ;address of volume ID sector
	ld l,$0E       ;bc = reserved sectors
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld l,$2C       ;ude = root dir first cluster
	ld de,(hl)
	ld l,0     ; hl &= $FFF800
	res 0,h
	push hl
	push bc
	pop hl
	ld b,9     ; reserved sectors *= 512
.multloop3:
	add hl,hl
	djnz .multloop3
;start of cluster map
	ld bc,$2000 ; add two 8-sector FATs
	add hl,bc   ; reserved sector size + FAT sectors size
	ex hl,de
	ld b,10     ; root dir first cluster *= 1024
.multloop2:
	add hl,hl
	djnz .multloop2
	add hl,de   ; add reserved sectors and FAT sectors
	pop bc
	add hl,bc   ; add drive base address
	ret
