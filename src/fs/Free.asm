;@DOES Free space allocated to a file
;@INPUT int fs_Free(void *fd);
;@OUTPUT number of sectors freed.
;@NOTE will sanity-check the filesystem if cluster map file is not found.
fs_Free:
	ld bc,fs_cluster_map_file
	push bc
	call fs_OpenFile
	pop bc
	jq c,fs_SanityCheck
	pop bc,de
	push de,bc
	push hl
	ex hl,de
	ld bc,fsentry_filesector
	add hl,bc
	ld de,(hl)
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ex.s hl,de
	pop de
	add hl,de
	ex hl,de
	ld hl,$FF0000
	push bc
	call sys_WriteFlash
	pop hl
	or a,a
	ret

