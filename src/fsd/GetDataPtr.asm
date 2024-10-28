;@DOES Return a pointer to a file descriptor's data at the current offset.
;@INPUT void* fsd_GetDataPtr(void** fd);
;@OUTPUT 0 if failed.
fsd_GetDataPtr:
	pop bc,hl
	push hl,bc
.entryhl:
	call fsd_IsOpen.entryhl
	jr z,.fail
	ld bc,fsd_DataPtr
	add hl,bc
	ld de,(hl)
	ld c,fsd_DataOffset
	ld hl,(hl)
	add hl,de
	ret
.fail:
	xor a,a
	sbc hl,hl
	ret

