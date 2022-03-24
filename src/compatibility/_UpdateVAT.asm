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
	ld de,0
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	or a,a
	push hl
	sbc hl,bc ; var ptr -= address shifting started at
	push de
	ld de,(ti.scrapMem)
	sbc hl,de ; var ptr -= amount shifted by
	pop de,hl
	jr c,.dont_set_var_size
; if var ptr <= address shifting started at + amount shifted by, resize the variable
	ld (hl),d
	dec hl
	ld (hl),e
	inc hl
.dont_set_var_size:
	inc hl
	pop de

	add hl,de ; add the amount shifted up by
	push hl
	inc sp
	pop af
	dec sp
	ld (iy-6),a ; upper byte of data pointer
	ld (iy-5),h ; high byte of data pointer
	ld (iy-4),l ; low byte of data pointer
.next:
	ld a,(iy-7)
	or a,a
	jr z,.finished
.nameloop:
	dec iy
	dec a
	jr nz,.nameloop
	jr .loop
.finished:
	ld (ti.pTemp),iy
	ld iy,ti.flags
	ret
