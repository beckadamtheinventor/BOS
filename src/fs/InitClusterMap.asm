;@DOES initialize cluster map given data within the file system.
;@INPUT void fs_InitClusterMap(void);
;@NOTE uses bos.safeRAM as scrap.
fs_InitClusterMap:
	ld hl,-3
	call ti._frameset

	ld de,fs_cluster_map_file
	push de
	call fs_OpenFile
	pop de
	jq c,.create_cmap
	; ld bc,0
	; push bc,hl
	; ld c,1
	; push bc
	; ld bc,7040
	; push bc
	; ld bc,$03E000
	; push bc
	; call fs_Write
	; pop bc,bc,bc,hl,bc
	ld hl,fs_cluster_map_file
	push hl
	call fs_GetFilePtr
	ld (ix-3),hl
	pop de
	ex hl,de
	ld bc,fs_cmap_length
	ld hl,safeRAM
.sectorcheckloop:
	ld a,(de)
	or a,a
	jq z,.next
	ld a,$FF
.next:
	ld (hl),a
	inc hl
	inc de
	dec bc
	ld a,c
	or a,b
	jq nz,.sectorcheckloop
	ld hl,safeRAM
	ld de,(ix-3)
	ld bc,fs_cmap_length
	push bc,hl,de
	call sys_FlashUnlock
	call sys_WriteFlashFullRam
	call sys_FlashLock
	pop bc,bc,bc
	jq .start_traversing

.create_cmap:
	ld bc,fs_cmap_length
	push bc
	ld c,fd_system+fd_readonly
	push bc,de
	call fs_CreateFile
	pop bc,bc,bc

.start_traversing:
	call sys_FlashUnlock
	ld de,(ix-3)
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
	bit fsbit_subfile, (iy+fsentry_fileattr)
	jq z,.regular_file
	ld hl,(iy+fsentry_filesector)
	ex.s hl,de
	lea hl,iy
	ld l,0
	res 0,h
	add hl,de
	ld de,-$040000
	add hl,de
	call fs_CeilDivBySector
	ld de,(ix-3)
	add hl,de
	push hl
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	pop de
	ld b,l
	jq .mark_file_entry
.regular_file:
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld b,l
	ld de,(iy+fsentry_filesector)
	ex.s hl,de
	ld de,(ix-3)
	add hl,de
	ex hl,de
.mark_file_entry:
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

