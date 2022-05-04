
;@DOES return the Nth VAT entry
;@INPUT HL = VAT entry number
;@OUTPUT HL = VAT entry pointer
_GetVATEntryN:
	ld iy,top_of_vat
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.finished
.loop:
	ld a,(iy-6)  ; upper byte of data pointer
	ld d,(iy-5)  ; high byte of data pointer
	ld e,(iy-4)  ; low byte of data pointer
	or a,d
	or a,e
	jr z,.fail
	ld a,(iy-7)
	lea iy,iy-7
	or a,a
	jr z,.fail
	ld b,a
.skip_name_loop:
	dec iy
	djnz .skip_name_loop
	ld de,1
	sbc hl,de
	jr nz,.loop
.finished:
	lea hl,iy
	db $01 ; dummify 3 bytes (next two instructions)
.fail:
	scf
	sbc hl,hl

	ld iy,ti.flags
	ret
