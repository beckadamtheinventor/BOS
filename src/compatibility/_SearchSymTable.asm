;@DOES Search the symbol table (VAT) for a file specified in OP1
;@INPUT Same as ti.ChkFindSym. 0xFF is treated as a wildcard.
;@OUTPUT Same as ti.ChkFindSym.
;@DESTROYS af, bc, iy
_SearchSymTable:
	ld iy,(ti.progPtr)
.search_vat_loop:
	ld hl,(ti.pTemp)
	lea de,iy
	or a,a
	sbc hl,de
	ret nc
	ld a,(ti.OP1)
	ld b,(iy-7)
	ld c,b
	inc a
	jr z,.check_name ; skip checking the variable type byte if searching with a wildcard (0xFF)
	dec a
	cp a,(iy-1)
	jr nz,.next_vat_entry ; skip this entry if it's not the same type we're searching for
	ld a,8
	cp a,b
	jr nc,.check_name ; only check up to 8 bytes of the file name
	ld b,a
.check_name:
	lea hl,iy-8
	ld de,ti.OP1+1
.check_name_loop:
	ld a,(de)
	inc a
	jr z,.check_next_character ; don't check this character against the vat entry's file name if it's a wildcard (0xFF)
	dec a
	sub a,(hl)
	jr nz,.next_vat_entry ; skip this entry if the names don't match
.check_next_character:
	dec de
	inc hl
	djnz .check_name_loop
	or a,(hl)
	jr z,.return_vat_entry ; return this entry if the name lengths match
	ld a,c
	cp a,8
	jr z,.return_vat_entry ; return this entry if the name length is the maximum length (8)
.next_vat_entry:
	lea iy,iy-7
	ld b,c
.skip_name_loop:
	dec iy
	djnz .skip_name_loop
	jr .search_vat_loop
.return_vat_entry:
	ld de,(iy-8) ; load deu with (iy-6)
	ld d,(iy-5)
	ld e,(iy-4)
	lea hl,iy-3
	ret
