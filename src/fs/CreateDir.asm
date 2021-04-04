
;@DOES Create a directory given a path and return a file descriptor.
;@INPUT void *fs_CreateDir(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create directory. 
fs_CreateDir:
	ld hl,-12
	call ti._frameset
	ld bc,(ix+6)
	push bc
	call fs_ParentDir
	jq c,.fail
	ex (sp),hl
	call sys_Free ;free memory malloc'd by fs_ParentDir
	call fs_OpenFile
	jq c,.fail  ; fail if parent dir not found
	ld bc,$C
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	pop bc
	ld (ix-3),hl ; save parent directory sector
	ld hl,48 ;minimum directory size
	ld de,(ix+9)
	ld bc,(ix+6)
	push hl,de,bc
	call fs_CreateFile
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail
	ld (ix-6),hl ; save new directory file descriptor
	ld bc,$C
	add hl,bc
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	ld (ix-9),hl ; save pointer to new directory data section
	ld bc,32
	push bc
	call sys_Malloc
	jq c,.fail
	ex hl,de
	pop bc
	ld hl,.path_back_entry
	ld (ix-12),de ; save pointer to malloc'd memory to free later
	ldir
	ld hl,(ix-12)
	ld c,$C
	add hl,bc
	push hl
	ld bc,(ix-9)
	push bc
	call fs_GetSector
	pop bc
	ex hl,de
	pop hl
	ld (hl),e  ; write "." entry to point to current directory
	inc hl
	ld (hl),d
	ld bc,$F
	add hl,bc
	ld bc,(ix-3)
	ld (hl),c  ; write ".." entry to point to parent directory
	inc hl
	ld (hl),b
	call sys_FlashUnlock
	ld de,(ix-9)
	ld hl,(ix-12)
	ld bc,32
	push bc,hl,de
	call sys_WriteFlashFullRam
	pop bc
;maybe verify end of directory marker here
	call sys_FlashLock
	call sys_Free ; free previously malloc'd memory
	pop bc,bc
	ld hl,(ix-6)
	xor a,a
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.path_back_entry:
	db ".          ",f_subdir,0,0,0,0
	db "..         ",f_subdir,0,0,0,0

