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
	ld hl,(iy-8) ; set hlu with upper byte of data pointer
	ld a,(iy-6)  ; upper byte of data pointer
	ld h,(iy-5)  ; high byte of data pointer
	ld l,(iy-4)  ; low byte of data pointer
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
	ld (iy-6),a ; upper byte of new data pointer
	ld (iy-5),h ; high byte of new data pointer
	ld (iy-4),l ; low byte of new data pointer

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
	ld a,(iy-1)
	cp a,ti.AppVarObj
	jr z,.skip_name
	cp a,ti.TempProgObj
	jr z,.skip_name
	cp a,ti.EquObj
	jr c,.skip_3_byte_name
	cp a,ti.ProtProgObj
	jr nc,.skip_3_byte_name
.skip_name:
	ld a,(iy-7)
	or a,a
	lea iy,iy-7
	jr z,.loop
.skip_name_loop:
	dec iy
	dec a
	jr nz,.skip_name_loop
	jr .loop
.skip_3_byte_name:
	lea iy,iy-10
	jr .loop
