;@DOES Copy a file given paths and return a file descriptor.
;@INPUT void *fs_CopyFile(const char *src, const char *dest);
;@OUTPUT file descriptor of new file. Returns 0 if failed.
fs_CopyFile:
	ld hl,-10
	call ti._frameset
	ld (ix-3),iy
	ld (ix-7),0
	ld hl,(ix+9) ; dest file
	push hl
	call fs_BaseName.entryhl
	ld a,(hl)
	cp a,'/'
	jr nz,.different_dest_name
	ld hl,(ix+6) ; source file
	call fs_BaseName.entryhl
	ex (sp),hl ; save source file base name, restore dest file path
	push hl
	call fs_JoinPath
	pop bc
	ld (ix-9),hl ; save dest file path joined with source base name
	ex (sp),hl ; then pass it on as the new dest file path
.different_dest_name:
	call fs_OpenFile
	jr nc,.fail ; fail if the destination exists
	ld hl,(ix+6) ; source file
	ex (sp),hl
	call fs_OpenFile
	jq c,.fail ; fail if the source doesnt exist
	ld bc,fsentry_fileattr
	add hl,bc
	ld a,(hl)
	ld (ix-10),a
	call fs_GetFDLen
	ld (ix-6),hl
	call fs_GetFDPtr
	pop bc
	ld bc,(ix-6)
	push bc,hl ; len, data
	ld hl,(ix+9)
	ld a,(ix-10)
	and a,1 shl fd_hidden or 1 shl fd_device or 1 shl fd_elevated
	ld c,a
	push bc,hl ; flags, path
	call fs_WriteNewFile ; write destination file
	jr c,.fail
	db $01
.fail:
	or a,a
	sbc hl,hl
	push hl
	ld hl,(ix-9)
	call sys_Free.entryhl
	pop hl
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret
