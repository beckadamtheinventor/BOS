;@DOES Create a VAT entry
;@INPUT OP1 = var type and var name
;@INPUT HL = pointer to file data, BC = file data length
;@OUTPUT Cf set if failed, hl = pointer to VAT entry
;@NOTE The only time this fails is if the VAT grows into an already allocated block of malloc memory, or if the VAT is corrupted.
_AddVATEntry:
	ld iyl,0
	ld a,(ti.OP1)
	cp a,ti.NewEquObj
	jr z,.maybe_write_length
	cp a,ti.AppVarObj
	jr z,.maybe_write_length
	cp a,ti.TempProgObj
	jr z,.maybe_write_length
	cp a,ti.EquObj
	jr c,.dont_write_length
	cp a,ti.GDBObj
	ccf
	jr nc,.maybe_write_length
; fail on unknown variable types for now
	pop hl
	scf
	ret
.maybe_write_length:
	ex hl,de
	call ti.ChkInRam
	ex hl,de
	jr z,.dont_write_length
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	inc iyl
.dont_write_length:
	ld de,(ti.pTemp)
	push de,hl
	ld hl,ti.OP1
	ld a,(hl)
	ld (de),a
	dec de
	xor a,a
	ld (de),a
	dec de
	ld (de),a
	inc hl
	ex hl,de
	pop bc ; data pointer
	dec hl
	ld (hl),c
	dec hl
	ld (hl),b
	dec hl
	call _SetAToBCU
	ld (hl),a
	ld b,a
	ld a,iyl ; check if we need to write a name length byte
	or a,a
	jr nz,.write_name_length
	ex hl,de
	ld b,3
	jr .copy_name_loop
.write_name_length:
	ld (hl),b ; var name length byte
	dec hl
	ex hl,de
.copy_name_loop:
	dec de
	ld a,(hl)
	ld (de),a
	inc hl
	djnz .copy_name_loop

	dec de
	ld (ti.pTemp),de ; save new end of VAT
	ex hl,de
	dec hl
	ld (hl),b

	ld bc,bottom_of_malloc_RAM
	or a,a
	sbc hl,bc ;ptr - bottom_of_malloc_RAM
	jr nc,.ptr_is_valid
	pop hl
	ret
.ptr_is_valid:
	add hl,bc
	ld c,5
	call ti._ishru
	ld bc,malloc_cache ;index the malloc cache
	add hl,bc ;hl now points to 8-bit malloc cache entry
	ld a,(hl)
	or a,a ; unset the carry flag
	pop hl
	ccf ; set the carry flag
	ret nz ; return with carry flag set if malloc cache indicates the block is allocated
	ccf ; unset the carry flag
	ret


