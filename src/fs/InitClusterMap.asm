;@DOES initialize cluster map given data within the file system.
;@INPUT void fs_InitClusterMap(void);
fs_InitClusterMap:
	ld hl,-3
	call ti._frameset
	call sys_FlashUnlock
	ld bc,7040
	push bc
	ld c,0
	push bc
	ld bc,.cluster_file
	push bc
	call fs_OpenFile
	call c,fs_CreateFile
	pop bc,bc,bc
	ld bc,0
	push bc,hl
	ld c,1
	push bc
	ld bc,7040
	push bc
	ld bc,$03E000
	push bc
	call fs_Write
	pop bc,bc,bc,hl,bc

	ld bc,fsentry_filesector
	add hl,bc
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	ld (ix-3),hl
	ex hl,de
	ld a,$FE
	call sys_WriteFlashA
	ld iy,$040000
	call .traverse

	call sys_FlashLock
	ld sp,ix
	pop ix
	ret
.traverse:
	ld a,(iy)
	or a,a
	ret z
	inc a
	ret z
	cp a,'.'+1
	jq z,.traverse_next
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	push iy
	call fs_CeilDivBySector
	pop iy
	ld b,l
	ld de,(iy+fsentry_filesector)
	ex.s hl,de
	ld de,(ix-3)
	add hl,de
	ex hl,de
	push iy
	ld c,$FE
.mark_file_loop:
	push bc,de
	ld a,c
	call sys_WriteFlashA
	pop de,bc
	inc de
	djnz .mark_file_loop
	pop iy
	bit fsbit_subdirectory, (iy+fsentry_fileattr)
	call nz,.traverse_into
.traverse_next:
	lea iy,iy+16
	jq .traverse
.traverse_into:
	push iy
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	call .traverse
	pop iy
	ret


.cluster_file:
	db "/dev/cmap.dat",0

