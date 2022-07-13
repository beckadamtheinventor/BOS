;@DOES Return a pointer to a free file descriptor, allocating new directory sections if needed.
;@INPUT void *fs_AllocDescriptor(void *fd);
;@OUTPUT pointer to new empty file descriptor. returns -1 and Cf set if failed
fs_AllocDescriptor:
	pop bc,hl
	push hl,bc
.entryfd:
	push hl
	call fs_GetFDPtr
	pop bc
.entry:
.get_end_of_dir_loop_entry:
	ld bc,fs_file_desc_size
	db $3E ; dummify next instruction
.get_end_of_dir_loop:
	add hl,bc
	ld a,(hl)
	inc a
	ret z
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

.allocate_dir_section: ; allocate a new directory section and return it
	ld bc,fs_directory_size
	push hl,bc
	call fs_Alloc ; allocate another directory section
	push hl
	call sys_FlashUnlock
	pop hl
	pop bc,de
	ret c
	push hl
	ld a,l
	call sys_WriteFlashA
	pop hl
	push hl
	ld a,h
	call sys_WriteFlashA
	pop hl
	push hl
	ld bc,fs_directory_size-fs_file_desc_size
	add hl,bc
	ex hl,de
	ld a,$FE ; directory extender byte
	call sys_WriteFlashA
	call sys_FlashLock
	pop hl
	ret
