;@DOES Create a file entry (uninitialized) given a path and return a file descriptor.
;@INPUT void *fs_CreateFileEntry(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create file.
fs_CreateFileEntry:
	ld hl,-19
	call ti._frameset
	xor a,a
	sbc hl,hl
	ld (ix-3),hl
	ld hl,(ix+6)
	or a,(hl)
	jq z,.fail
	cp a,' '
	jq z,.fail
	push hl
	call fs_OpenFile
	jq nc,.fail ;fail if file exists
	call fs_ParentDir
	ld (ix-3),hl
	ex (sp),hl
	call fs_OpenFile
	jq c,.fail   ; fail if parent dir doesn't exist
	ex (sp),hl
	pop iy
	bit fsbit_subdirectory,(iy+fsentry_fileattr)
	jq z,.fail ;fail if parent dir is not a dir
	ld hl,(ix+6)
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	dec hl
	ld a,'/'
	cp a,(hl)
	jq nz,.doesntendwithslash
	dec hl
	dec bc
.doesntendwithslash:
	cpdr
	inc hl
	jq nz,.doesntstartwithslash
	inc hl
.doesntstartwithslash:
	push hl
	pea ix-19
	call fs_StrToFileEntry
	pop bc,bc

	ld a, (ix+9)
	ld (ix + fsentry_fileattr - 19), a     ;setup new file descriptor contents

	ld hl,(ix-3)
.write_descriptor:
	push hl
	call fs_GetFilePtr
	pop de
.get_end_of_dir_loop_entry:
	ld bc,16
	db $3E ; dummify next instruction
.get_end_of_dir_loop:
	add hl,bc
	ld a,(hl)
	inc a
	jq z,.found_end_of_dir
	inc a
	jq nz,.get_end_of_dir_loop
.seek_next_dir_section:
	ld c,fsentry_filesector+1
	add hl,bc
	ld a,(hl)
	dec hl
	cp a,(hl)
	jq nz,.next_section_allocated
	inc a
	jq z,.allocate_dir_section
.next_section_allocated:
	ld hl,(hl)
	call fs_GetSectorAddress.entry
	jq .get_end_of_dir_loop_entry
.allocate_dir_section:
	ld c,b
	ld b,2
	push hl,bc
	call fs_Alloc ; allocate another directory section
	jq c,.fail
	pop bc,de
	push hl
	ld a,l
	call sys_WriteFlashA
	pop hl
	push hl
	ld a,h
	call sys_WriteFlashA
	pop hl
	push hl
	inc h
	xor a,a
	ld l,a
	ex hl,de
	dec a
	dec a
	call sys_WriteFlashA
	pop hl
.found_end_of_dir:
	ex hl,de
	lea hl,ix-19
	ld bc,fsentry_filesector ; only write up until and including attribute byte
	push de
	call sys_WriteFlash
	pop hl
	db $01
.fail:
	xor a,a
	sbc hl,hl
	push hl,af
	ld hl,(ix-3)
	push hl
	call sys_Free
	pop bc,af,hl
	ld sp,ix
	pop ix
	ret
