;@DOES Create a file given a path and return a file descriptor.
;@INPUT void *fs_CreateFile(const char *path, uint8_t flags);
;@OUTPUT file descriptor. Returns 0 if failed to create file.
fs_CreateFile:
	ld hl,-25
	call ti._frameset
	ld bc,(ix+6)
	push bc
	call fs_OpenFile
	jq nc,.fail
	call ti._strlen
	pop de
	ld a,(de)
	cp a,'/'
	push de
	jq nz,.not_abs
	inc hl
	push hl
	call sys_Malloc
	ex hl,de
	pop hl
	ex (sp),hl
	push hl,de
	call ti._memcpy
	pop de,hl,bc
	jq .process_path
.not_abs:
	call fs_AbsPath
	pop bc
	push hl
.process_path:
	ld (ix-19),de
	push de
	ld bc,0
	xor a,a
	cpir
	dec hl
	ld (ix-22),hl
	dec hl
	dec hl
	dec bc
	dec bc
	ld a,'/'
	cpdr
	inc hl
	ld (hl),0
	call fs_OpenFile
	pop bc
	jq c,.fail
	push hl
	pop iy
	bit fsbit_subdirectory,(iy+fsentry_fileattr)
	jq z,.fail
	push hl
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	ld de,16
	add hl,de
	push iy,hl
	call fs_SetSize
	jq c,.fail
	pop hl,iy
	ld de,-32
	add hl,de
	ld (ix-25),hl
	ex.s hl,de
	pop hl
	push iy,de,hl
	or a,a
	sbc hl,hl
	ld (ix + fsentry_filesector - 16),hl
	ld (ix + fsentry_filelen - 16),l
	ld (ix + fsentry_filelen - 15),h
	ld l,1
	push hl
	ld c,16
	push bc
	pea ix-16
	call fs_Write
	pop bc,bc,bc,de,hl
	ld c,16
	add hl,bc
	push hl,de,bc
	ld c,1
	push bc
	ld bc,$FF0000
	push bc
	call fs_Write
	pop bc,bc,bc,bc,bc
	pop hl
	ld bc,(ix-25)
	add hl,bc
	db $01
.success:
	ld hl,(ix-25)
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

