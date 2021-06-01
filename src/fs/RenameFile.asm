;@DOES rename a file
;@INPUT void *fs_RenameFile(const char *directory, const char *old_name, const char *new_name);
;@OUTPUT file descriptor. returns zero if failed
fs_RenameFile:
	ld hl,-16
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
	lea de,ix-16
	ld bc,16
	push bc,de,hl
	ldir
	lea de,ix-16
	ld hl,(ix+12)
	ld bc,8
.copy_loop:
	ld a,(hl)
	or a,a
	jq z,.copy_ext
	ldi
	jp pe,.copy_loop
.copy_ext:
	lea de,ix-8
	ld c,3
	ldir
	call sys_WriteFlashFull
	pop hl,bc,bc
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

