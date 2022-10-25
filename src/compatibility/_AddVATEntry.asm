;@DOES Create a VAT entry
;@INPUT OP1 = var type and var name
;@INPUT HL = pointer to file data, BC = file data length
;@OUTPUT Cf set if failed, hl = pointer to VAT entry
;@NOTE The only time this fails is if the VAT grows into an already allocated block of malloc memory, or if the VAT is corrupted.
_AddVATEntry:
	ld de,(ti.pTemp)
	push de,hl,bc
	ld hl,ti.OP1
	dec de
	ld a,(hl)
	ld (de),a
	dec de
	inc hl
	push hl
	ld bc,8
	push bc
	xor a,a
	cpir
	pop hl
	scf
	sbc hl,bc
	ex (sp),hl
	pop bc
	ld a,c
	pop bc
	ex hl,de
	ld (hl),c ; data length low byte
	dec hl
	ld (hl),b ; data length high byte
	dec hl
	dec hl
	dec hl
	pop bc
	ld (hl),bc  ; data pointer
	push hl
	dec hl
	ld (hl),a ; var name length byte
	ex hl,de
	ld b,a
.copy_name_loop:
	dec de
	ld a,(hl)
	ld (de),a
	inc hl
	djnz .copy_name_loop
	pop hl
	; reverse the endianness of the data pointer
	ld a,(hl)
	inc hl
	inc hl
	ld b,(hl)
	ld (hl),a
	dec hl
	dec hl
	ld (hl),b

	ld (ti.pTemp),de ; save new end of VAT
	ex hl,de

	xor a,a
	dec hl
	ld (hl),a
	dec hl
	ld (hl),a
	dec hl
	ld (hl),a

	ld bc,bottom_of_malloc_RAM
	or a,a
	sbc hl,bc ;ptr - bottom_of_malloc_RAM
	jr c,.fail
	add hl,bc
	ld c,5
	call ti._ishru
	ld bc,malloc_cache ;index the malloc cache
	add hl,bc ;hl now points to 8-bit malloc cache entry
	ld a,(hl)
	or a,a
	scf
	jr nz,.fail
	ccf
.fail:
	pop hl
	ret


