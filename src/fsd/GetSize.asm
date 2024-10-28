;@DOES Return the data size of a file descriptor.
;@INPUT int fsd_GetSize(void** fd);
;@OUTPUT -1 if failed.
fsd_GetSize:
	pop bc,hl
	push hl,bc
.entryhl:
	call fsd_IsOpen.entryhl
	jr z,.fail
	ld bc,fsd_DataLen
	add hl,bc
	ld hl,(hl)
	ret
.fail:
	scf
	sbc hl,hl
	ret

