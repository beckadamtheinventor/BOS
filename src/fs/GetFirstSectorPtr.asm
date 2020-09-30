;@DOES return the first sector of a file descriptor
;@INPUT fs_GetFirstSectorPtr(void *fd);
fs_GetFirstSectorPtr:
	pop bc
	pop hl
	push hl
	push bc
	add hl,de  ;check if fd is null
	or a,a
	sbc hl,de
	jr z,.fail
	inc hl     ;check if fd is -1
	add hl,de
	or a,a
	sbc hl,de
	jr z,.fail
	dec hl
	push hl
	call fs_DriveLetterFromPtr
	pop hl
	jq c,.fail
	ld (ScrapByte),a
	ld bc,$12
	add hl,bc
	ld bc,(hl)  ;upper byte of file starting cluster
	ld c,$1A - $12
	add hl,bc
	ld c,(hl) ;low two bytes of file starting cluster
	inc hl
	ld b,(hl)
	ld (ScrapMem),bc
	ld (ScrapMem+2),a
	ld hl,(ScrapMem)
	push hl
	ld a,(ScrapByte)
	call fs_DataSection
	pop bc
	jq c,.fail
	add hl,bc
	ret
.fail:
	scf
	sbc hl,hl
	ret
