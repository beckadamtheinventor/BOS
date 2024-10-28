;@DOES Return the read/write offset of a file descriptor.
;@INPUT int fsd_Tell(void** fd);
;@OUTPUT -1 if failed.
fsd_Tell:
	pop bc,hl
	push hl,bc
.entryhl:
	call fsd_IsOpen.entryhl
	jr z,.fail
	ld bc,fsd_DataOffset
	add hl,bc
	ld hl,(hl)
	ret
.fail:
	scf
	sbc hl,hl
	ret

