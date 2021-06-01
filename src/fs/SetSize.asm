
;@DOES Resizes a file descriptor.
;@INPUT bool fs_SetSize(int len, void *fd);
;@OUTPUT true if resizing succeeded
;@NOTE Will allocate enough sectors to contain len bytes.
fs_SetSize:
	ld hl,-23
	call ti._frameset
	ld (ix-23),iy
	ld bc,(ix+9)
	push bc
	call fs_CheckWritableFD
	dec a
	jq nz,.fail
	pop iy
	ld a,(iy + fsentry_fileattr)
	ld (ix-20),a
	ld hl,(iy + fsentry_filesector)
	ld (ix-19),hl
	ld de,(iy + fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld a,l
	or a,h
	jq nz,.allocate_from_nonempty_file

	res fsbit_subfile, (ix-20)

	ld hl,(ix+6)
	push hl
	call fs_Alloc ;allocate space for new file
	jq c,.fail
	pop bc
	ld (ix-19),hl
	jq .update_file_entry

.allocate_from_nonempty_file:
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	ld de,(ix+6)
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.update_file_entry ;file resize does not require any more clusters

	bit fsbit_subfile, (ix-20)
	res fsbit_subfile, (ix-20)

	push iy
	call z, fs_Free ;free the old file clusters if not a subfile
	pop iy

	ld hl,(iy+fsentry_filelen)
	ex.s hl,de
	push de
	ld hl,(ix+6)
	push hl
	call fs_Alloc ;allocate space for new file
	jq c,.fail
	pop bc
	ld (ix-19),hl
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	ld hl,(iy + fsentry_filesector)
	bit fsbit_subfile, (iy + fsentry_fileattr)
	jq z,.rewrite_non_subfile
	ex.s hl,de
	lea hl,iy
	ld l,0
	res 0,h
	add hl,de
	jq .rewrite_file
.rewrite_non_subfile:
	push hl
	call fs_GetSectorAddress
	pop bc
.rewrite_file:
	ex (sp),hl
	push hl
	call sys_WriteFlashFullRam ;rewrite file contents at new location
	pop bc,bc,bc

.update_file_entry:
	ld iy,(ix+9)
	lea de,ix-16
	lea hl,iy
	ld bc,16
	push bc
	ld c,12
	ldir
	ld a,(ix-20) ;load new file attribute byte
	ld (ix + fsentry_fileattr - 16),a
	ld bc,(ix-19)
	ld (ix-4),bc
	ld bc,(ix+6)
	ld (ix-2),c
	ld (ix-1),b
	pea ix-16
	push iy
	call sys_WriteFlashFullRam
	pop bc,bc,bc

.success:
	db $3E
.fail:
	xor a,a
	or a,a
	ld iy,(ix-23)
	ld sp,ix
	pop ix
	ret







