;@DOES Return length of file data given a file descriptor
;@INPUT int fs_GetFDLen(void *fd);
;@OUTPUT length of file data
;@DESTROYS HL,DE
fs_GetFDLen:
	pop de,hl
	push hl,de
	ld de,$E
	add hl,de
	ld de,(hl)
	ex.s hl,de
	ret
