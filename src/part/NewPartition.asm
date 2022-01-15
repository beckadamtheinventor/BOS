;@DOES Create a new empty partition
;@INPUT part_NewPartition(const char *name, unsigned int size);
;@OUTPUT hl = descriptor, or -1 and Cf set if failed to allocate partition
;@NOTE size is measured in bytes
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
	push hl
	call ti._frameset0
	ld hl,(ix+9) ; const char *name

	ld de,(ix+3) ; new partition descriptor

	ld sp,ix
	pop ix,hl
	ret
