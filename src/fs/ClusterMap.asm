
;@DOES return a pointer to a given drive's first cluster map.
;@INPUT a = drive letter
;@OUTPUT hl = cluster map
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
	ld (ScrapMem),hl  ; get sector address of hl
	ld hl,ScrapMem
	xor a,a
	ld (hl),a
	inc hl
	ld (hl),a
	dec hl
	ld hl,(hl)        ; hl is now the sector address
	push hl
	push bc
	pop hl
	ld b,9     ; reserved sectors *= 512
.multloop3:
	add hl,hl
	djnz .multloop3
	pop bc
	add hl,bc
	or a,a
	ret
