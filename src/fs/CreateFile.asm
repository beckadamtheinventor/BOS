;@DOES Create a file given a path and return a file descriptor.
;@INPUT void *fs_CreateFile(const char *path, uint8_t flags, int len);
;@OUTPUT file descriptor. Returns 0 if failed to create file.
;@NOTE if len is zero, the file data section will not be initialized.
fs_CreateFile:
	ld hl,-7
	call ti._frameset

	ld hl,(ix+6)
	ld e,(ix+9)
	push de,hl
	call fs_OpenFile
	jr nc,.check_entry
	call fs_CreateFileEntry
	pop de,de
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail
.alloc_uninited_descriptor:
	ld (ix-7),hl ; save file descriptor

	ld hl,(ix+12)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.done

	ld (ix-2),l
	ld (ix-1),h
.alloc:
	push hl
	call fs_Alloc ;allocate space for file
	jq c,.fail
	pop bc
	ld (ix-4),l
	ld (ix-3),h
	jr .writedescriptor

.check_entry:
	push hl
	call fs_GetFDPtr.entry
	jr nc,.fail ; fail if trying to create an existing file with an already initialized data section.
	pop hl
	jr .alloc_uninited_descriptor

; .zerolen:
	; scf
	; sbc hl,hl
	; ld (ix-3),hl
	; ld (ix-4),l
.writedescriptor:
	ld hl,(ix-7) ; restore file descriptor
	ld bc,fsentry_filesector
	add hl,bc
	ex hl,de
	lea hl,ix-4
	ld c,4
	call sys_FlashUnlock
	call sys_WriteFlash
	call sys_FlashLock
.done:
	ld hl,(ix-7)
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
