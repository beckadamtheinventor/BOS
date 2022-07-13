;@DOES get the memory address of a given sector address.
;@INPUT void *fs_GetSectorAddress(uint16_t sector);
fs_GetSectorAddress:
	pop de,hl
	push hl,de
.entry:
	ex hl,de
	ex.s hl,de
	; bit 7,h
	; jr nz,.ram_sector
	ld b,fs_sector_size_bits
	ld de,start_of_user_archive
.mult_loop:
	add hl,hl
	djnz .mult_loop
	add hl,de
	ret
; .ram_sector:
	; res 7,h
	; call _GetVATEntryN
	; inc hl
	; ld a,(hl)
	; inc hl
	; ld d,(hl)
	; inc hl
	; ld l,(hl)
	; ld h,d
	; jp _SetHLUToA
