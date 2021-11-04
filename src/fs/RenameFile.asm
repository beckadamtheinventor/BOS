;@DOES rename a file
;@INPUT void *fs_RenameFile(const char *directory, const char *old_name, const char *new_name);
;@OUTPUT file descriptor. returns zero if failed
fs_RenameFile:
	ld hl,-19
	call ti._frameset
	push iy
	ld hl,(ix+6)
	push hl
	call fs_CheckWritable
	dec a
	jq nz,.fail
	call fs_OpenFile
	; jq c,.fail ;no need to check if the file exists twice
	pop bc
	ld bc,(ix+9)
	push hl,bc
	call fs_OpenFileInDir
	jq c,.fail
	pop bc,bc
	lea de,ix+fsentry_fileattr-19
	ld bc,fsentry_fileattr ; copy old file descriptor attribute byte, sector address, and length
	add hl,bc
	ld c,5
	ldir
	ld hl,(ix+12)
	push hl
	pea ix-16
	call fs_StrToFileEntry
	pop hl,bc
	ld (ix-3),hl ; setting this outside of malloc memory so the routine we're jumping to doesn't unintentionally free anything in malloc memory
	ld hl,(ix+9) ; grab parent directory name
	jq fs_CreateFileEntry.write_descriptor
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

