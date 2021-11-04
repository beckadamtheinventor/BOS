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
	call fs_CreateFileEntry
	pop de,de
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.fail

	ld bc,(ix+12)
	ld a,c
	or a,b
	jq z,.done

	ld (ix-7),hl ; save file descriptor
	ld (ix-2),c
	ld (ix-1),b
	push bc
	call fs_Alloc ;allocate space for file
	jq c,.fail
	pop bc
	ld (ix-4),l
	ld (ix-3),h
	ld hl,(ix-7) ; restore file descriptor
	ld bc,fsentry_filesector
	add hl,bc
	ex hl,de
	lea hl,ix-4
	ld c,4
	call sys_WriteFlash
	ld hl,(ix-7)
.done:
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
