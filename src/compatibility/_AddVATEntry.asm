;@DOES Create a VAT entry
;@INPUT OP1 = var type and var name
;@INPUT HL = pointer to data structure
;@OUTPUT Cf set if failed.
;@NOTE The only time this fails is if the VAT grows into an already allocated block of malloc memory, or if the VAT is corrupted.
_AddVATEntry:
	push iy
	ld iy,(ti.pTemp)
	pea iy-6
	push hl
	ld hl,ti.OP1
	lea iy,iy-6
	ld b,0
.nameloop:
	inc hl
	dec iy
	ld a,(hl)
	ld (iy),a
	or a,a
	jr nz,.nameloop
	or a,b
	jr nz,.hasname
	inc b
	ld (iy),b
	ld a,'?'
	ld (iy-1),a
	lea iy,iy-2
.hasname:
	pop hl ; pointer to data structure
	ex (sp),iy ; exchange bottom of entry with pointer to entry name length
	ld (iy),b
	push hl
	inc sp
	pop af
	dec sp
	ld (iy+1),a
	ld (iy+2),h
	ld (iy+3),l
	ld (iy+4),1
	ld (iy+5),0
	ld a,(ti.OP1)
	ld (iy+6),a
	pop hl
	ld (ti.pTemp),hl

	ld de,bottom_of_malloc_RAM
	or a,a
	sbc hl,de ;ptr - bottom_of_malloc_RAM
	jr c,.fail
	ld bc,65536
	sbc hl,bc
	ccf
	jr c,.fail
	add hl,bc
	ld c,5
	call ti._ishru
	ld de,malloc_cache ;index the malloc cache
	add hl,de ;hl now points to 8-bit malloc cache entry
	ld a,(hl)
	or a,a
	scf
	jr nz,.fail
	ccf
.fail:
	pop iy
	ret


