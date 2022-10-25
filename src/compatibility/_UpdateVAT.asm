;@DOES update the VAT
;@INPUT hl = amount shifted by
;@INPUT de = address shifted from
_UpdateVAT:
	push de
	pop bc
	ex hl,de
	ld iy,(ti.progPtr)
.loop:
	push de
	ld hl,(ti.pTemp)
	lea de,iy
	or a,a
	sbc hl,de
	pop de
	ret nc
	ld hl,(iy-7) ; set hlu with upper byte of data pointer
	ld a,(iy-5)  ; upper byte of data pointer
	ld h,(iy-4)  ; high byte of data pointer
	ld l,(iy-3)  ; low byte of data pointer
	or a,a
	sbc hl,bc ; compare against address shifting started at
	jr c,.next
	add hl,bc
	add hl,de ; var ptr += amount shifted

	; ld (iy-5),hl
	push hl
	inc sp
	pop af
	dec sp
	ld (iy-5),a ; upper byte of new data pointer
	ld (iy-4),h ; high byte of new data pointer
	ld (iy-3),l ; low byte of new data pointer

	; this routine shouldn't update the length of the variable being inserted into / deleted from, that's the user's job according to TIOS (iirc)
	; mlt de ; set DEU to 0 and D,E to unknown
	; ld d,(hl)
	; inc hl
	; ld e,(hl)
	; inc hl
	; add hl,de ; new var ptr + var len
	; or a,a
	; sbc hl,bc ; new var ptr + var len < address shifting started at
	; add hl,bc
	; jr nc,.dont_resize ; dont resize the var if the address shifting started at does not lie within it

	; sbc hl,de ; new var ptr + var len - (var len + 1)
	; push hl
	; ld hl,(ti.scrapMem)
	; add hl,de  ; var len + the amount shifted by
	; ex hl,de
	; pop hl
	; ld (hl),e
	; dec hl
	; ld (hl),d
	; dec hl
; .dont_resize:
.next:
	ld a,(iy-6)
	lea iy,iy-6
	or a,a
	ret z
.skip_name_loop:
	dec iy
	dec a
	jr nz,.skip_name_loop
	jr .loop
