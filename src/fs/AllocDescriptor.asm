;@DOES Return a pointer to a free file descriptor, allocating new directory sections if needed.
;@INPUT void *fs_AllocDescriptor(void *fd);
;@OUTPUT pointer to new empty file descriptor. returns -1 and Cf set if failed
fs_AllocDescriptor:
	pop bc,hl
	push hl,bc
.entryfd:
	call fs_GetFDPtr.entry
.entry:
    call fs_GetDirSize.entryptr ; returns pointer to empty entry or non-allocated dirextender in de
    ex hl,de
    ld a,(hl)
    cp a,fsentry_dirextender
    jr z,.allocate_dir_section
    or a,a
    ret

.allocate_dir_section: ; allocate a new directory section and return it
    ld bc,fsentry_filesector
    add hl,bc
	ld bc,fs_directory_size
	push hl,bc ; push pointer to sector address word, directory size
	call fs_Alloc ; allocate another directory section
	call sys_FlashUnlock
	pop bc,de
	ret c
	push hl ; push allocated sector address
	ld a,l ; write low byte
	call sys_WriteFlashA
	pop hl
    push hl
	ld a,h ; write high byte
	call sys_WriteFlashA
    pop hl
    call fs_GetSectorAddress.entry
    push hl ; push pointer to new directory section
    ld de,fs_directory_size-fs_file_desc_size
    add hl,de
    ex hl,de ; last entry of directory
	ld a,$FE ; directory extender byte
	call sys_WriteFlashA
	call sys_FlashLock
	pop hl
	ret
