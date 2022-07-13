
TODO. this file is unfinished.

;@DOES Create a new empty partition
;@INPUT part_NewPartition(unsigned int block_size, unsigned int size);
;@OUTPUT hl = descriptor, or -1 and Cf set if failed to allocate partition
;@NOTE size and block_size are measured in bytes
part_NewPartition:
	ld hl,fs_filesystem_address
	ld de,fs_partition_desc_size
	ld b,fs_sector_size/fs_partition_desc_size
.findemptyloop:
	ld a,(hl)
	inc a
	jr z,.found
	add hl,de
	djnz .findemptyloop
	scf
	sbc hl,hl
	ret
.found:
	push iy
	ld iy,0
	add iy,sp
	push hl
	ld hl,(iy+12) ; unsigned int size
	push hl
	call fs_Alloc
	pop hl
	
	pop de
	

	pop iy
	ret
