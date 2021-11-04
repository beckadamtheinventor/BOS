
;@DOES Create a directory given a path and return a file descriptor.
;@INPUT void *fs_CreateDir(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create directory. 
fs_CreateDir:
	ld de,1024 ;size of directory initial sector
.entry_de:
	ld hl,3
	add hl,sp
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ld l,(hl)
	push de,hl,bc
	call fs_CreateFile
	pop bc,bc,bc
	ret

