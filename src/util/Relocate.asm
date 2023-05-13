;@DOES Relocate code in data offsetting 24-bit values (offsets of data) by origin_delta.
;@INPUT void util_Relocate(void *data, unsigned int *offsets, int origin_delta);
;@NOTE relocates data in place. (data MUST be stored in ram, otherwise this will crash) offsets should be terminated with 0xffffff.
util_Relocate:
	call ti._frameset0
	push iy
	ld hl,(ix+6)
	ld iy,(ix+9)
	ld de,(ix+12)
.loop:
	ld bc,(iy)
	ld a,(iy+2)
	and a,b
	and a,c
	inc a
	jr z,.done
	push hl
	add hl,bc  ; get pointer to 24-bit word to be offset
	push hl
	ld hl,(hl) ; grab word
	add hl,de  ; add origin_delta
	ex (sp),hl
	pop bc
	ld (hl),bc ; set new 24-bit word
	pop hl
	lea iy,iy+3
	jr .loop
.done:
	pop iy
	pop ix
	ret
