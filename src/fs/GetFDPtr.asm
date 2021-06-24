;@DOES Return pointer to file data given a file descriptor
;@INPUT void *fs_GetFDPtr(void *fd);
;@OUTPUT pointer to file data
fs_GetFDPtr:
	pop bc,hl
	push hl,bc
	ld bc,$B
	add hl,bc
	bit fd_subfile,(hl)
	inc hl
	jq nz,.subfile
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	ret
.subfile:
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld l,0
	res 0,h
	add hl,bc
	ret
