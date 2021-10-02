;@DOES Free space allocated to a file
;@INPUT int fs_Free(void *fd);
;@OUTPUT number of sectors freed.
;@NOTE will sanity check the filesystem if cluster map file is not found.
fs_Free:
	ld bc,fs_cluster_map_file
	push bc
	call fs_GetFilePtr
	pop bc
	call c,fs_SanityCheck
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
	add hl,de ;hl points to cluster map at file sector#
	push hl,bc
	pop hl
	call fs_CeilDivBySector
	ex (sp),hl ;push number of file sectors, pop cluster map at file sector#
	ld de,$FF0000
	push de,hl ;push source and destination pointers
	call sys_WriteFlash
	pop bc,bc,hl ;return number of sectors freed
	or a,a
	ret

