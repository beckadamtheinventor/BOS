;@DOES get the memory address of a given sector address.
;@INPUT void *fs_GetSectorAddress(uint16_t sector);
fs_GetSectorAddress:
	pop de,hl
	push hl,de
.entry:
	ex hl,de
	ex.s hl,de
	ld e,a
	ld a,h
	cp a,$E0 ; ram descriptors start at $E000
	ld a,e
	jr nc,.ram_sector
	ld b,fs_sector_size_bits
	ld de,start_of_user_archive
.mult_loop:
	add hl,hl
	djnz .mult_loop
	add hl,de
	ret
.ram_sector:
	ld de,-$E000
	add hl,de
	call _GetVATEntryN
	inc hl
	ld a,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld l,(hl)
	ld h,d
	jp _SetHLUToA
