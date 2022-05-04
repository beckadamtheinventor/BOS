;@DOES update the VAT
;@INPUT hl = amount shifted by
;@INPUT de = address shifted from
_UpdateVAT:
	ld (ti.scrapMem),hl
	push de
	pop bc
	ex hl,de
	ld iy,top_of_vat
	ld (ti.progPtr),iy
.loop:
	ld hl,(iy-8) ; set hlu with upper byte of data pointer
	ld a,(iy-6)  ; upper byte of data pointer
	ld h,(iy-5)  ; high byte of data pointer
	ld l,(iy-4)  ; low byte of data pointer
	or a,h
	or a,l
	jr z,.finished
	sbc hl,bc ; compare against address shifting started at
	jr c,.next
	add hl,bc
	push de
	ld de,(ti.scrapMem)
	add hl,de ; var ptr += amount shifted

	push hl
	inc sp
	pop af
	dec sp
	ld (iy-6),a ; upper byte of new data pointer
	ld (iy-5),h ; high byte of new data pointer
	ld (iy-4),l ; low byte of new data pointer

	mlt de ; set DEU to 0 and D,E to unknown
	ld d,(hl)
	inc hl
	ld e,(hl)
	inc hl
	add hl,de ; new var ptr + var len
	or a,a
	sbc hl,bc ; new var ptr + var len < address shifting started at
	add hl,bc
	jr nc,.dont_resize ; dont resize the var if the address shifting started at does not lie within it

	sbc hl,de ; new var ptr + var len - (var len + 1)
	push hl
	ld hl,(ti.scrapMem)
	add hl,de  ; var len + the amount shifted by
	ex hl,de
	pop hl
	ld (hl),e
	dec hl
	ld (hl),d
	dec hl
.dont_resize:
	pop de
.next:
	ld a,(iy-7)
	lea iy,iy-7
	or a,a
	jr z,.finished
	ld b,a
.skip_name_loop:
	dec iy
	djnz .skip_name_loop
	jr .loop
.finished:
	ld (ti.pTemp),iy
	ld iy,ti.flags
	ret
