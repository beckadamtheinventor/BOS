
;@DOES Search the VAT for a file descriptor containing address in HL
;@OUTPUT HL = VAT entry number, DE = VAT entry pointer (high)
_GetVATEntryNFromPtr:
	ld (ti.scrapMem),hl
	push hl
	pop bc
	ex hl,de
	ld iy,top_of_vat
	ld (ti.progPtr),iy
	or a,a
	sbc hl,hl
	push hl
.loop:
	ld hl,(iy-8) ; set hlu with upper byte of data pointer
	ld a,(iy-6)  ; upper byte of data pointer
	ld h,(iy-5)  ; high byte of data pointer
	ld l,(iy-4)  ; low byte of data pointer
	or a,h
	or a,l
	jr z,.fail
	ld de,0
	ld e,(hl)
	inc hl
	ld d,(hl)
	dec hl
	sbc hl,bc ; compare against address
	jr c,.next ; skip if var < ptr
	sbc hl,de ; compate var - ptr < varlen
	jr c,.return_this
.next:
	ex (sp),hl
	inc hl
	ex (sp),hl
	ld a,(iy-7)
	or a,a
	jr z,.fail
.nameloop:
	dec iy
	dec a
	jr nz,.nameloop
	jr .loop
.fail:
	pop hl
	sbc hl,hl
	jr .finished
.return_this:
	add hl,de
	add hl,bc
	ex hl,de
	pop hl
.finished:
	ld iy,ti.flags
	ret

