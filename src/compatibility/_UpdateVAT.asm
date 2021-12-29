;@DOES update the VAT
;@INPUT hl = amount shifted up by
;@INPUT de = address to start shifting
_UpdateVAT:
	push de
	pop bc
	ex hl,de
	ld iy,top_of_vat
	ld (ti.progPtr),iy
.loop:
	ld hl,(iy-8) ; upper byte of data pointer
	ld a,(iy-6)
	ld h,(iy-5) ; high byte of data pointer
	ld l,(iy-4) ; low byte of data pointer
	or a,h
	or a,l
	jr z,.finished
	sbc hl,bc ; compare against address shifting started at
	jr c,.next
	add hl,bc
	add hl,de ; add the amount shifted up by
	
	
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
