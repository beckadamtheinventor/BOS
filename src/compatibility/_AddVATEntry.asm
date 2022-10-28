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
	jp c,.fail ; fail on unknown variable types for now
.maybe_write_length:
	ex hl,de
	call ti.ChkInRam
	ex hl,de
	jr z,.dont_write_length
	ld (hl),c
	inc hl
	ld (hl),b
	dec hl
	inc iyl
.dont_write_length:
	ld de,(ti.pTemp)
	push de,hl,bc
	ld hl,ti.OP1
	ld a,(hl)
	ld (de),a
	dec de
	xor a,a
	ld (de),a
	dec de
	ld (de),a
	inc hl
	push hl
	ld bc,8
	push bc
	cpir
	pop hl
	scf
	sbc hl,bc
	ex (sp),hl
	pop bc
	ld a,c
	pop bc
	ex hl,de
	; ld (hl),c ; data length low byte
	; dec hl
	; ld (hl),b ; data length high byte
	; dec hl
	dec hl
	dec hl
	dec hl
	pop bc
	ld (hl),bc  ; data pointer
	push hl
	ld c,a
	ld a,iyl ; check if we need to write a name length byte
	or a,a
	jr nz,.write_name_length
	ex hl,de
	ld b,3
	jr .copy_name_loop
.write_name_length:
	ld (hl),c ; var name length byte
	dec hl
	ex hl,de
	ld b,c
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

	dec de
	ld (ti.pTemp),de ; save new end of VAT
	ex hl,de
	dec hl
	ld (hl),b

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


