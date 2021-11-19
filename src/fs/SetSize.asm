
;@DOES Resizes a file descriptor.
;@INPUT void *fs_SetSize(int len, void *fd);
;@OUTPUT new file descriptor if success, -1 and Cf set if fail
;@NOTE New file contents will be empty, but old file data will be preserved until the next cleanup.
fs_SetSize:
	ld hl,-22
	call ti._frameset
	ld (ix-22),iy
	ld bc,(ix+9)
	push bc,bc,bc
	call fs_CheckWritableFD
	dec a
	jq nz,.fail
	pop hl
	lea de,ix-16
	ld bc,fsentry_fileattr
	ldir ; copy old descriptor into ram

	dec hl
	bit fsbit_subfile, (hl)
	call z, fs_Free ;free the old file clusters if not a subfile
	pop hl
	call fs_AllocDescriptor.entry
	jq c,.fail
	ld (ix-19),hl
	
	ld hl,(ix+6)
	push hl
	call fs_Alloc
	jq c,.fail
	ld (ix + fsentry_filesector - 16), hl ; set new file descriptor data pointer
	pop hl
	ld (ix + fsentry_filelen+0 - 16),l
	ld (ix + fsentry_filelen+1 - 16),h
	call sys_FlashUnlock
	pop de
	xor a,a
	call sys_WriteFlashA ; delete the old file descriptor

	ld de,(ix-19)
	lea hl,ix-16
	ld bc,16
	call sys_WriteFlash ; write the new file descriptor
.success:
	db $01
.fail:
	scf
	sbc hl,hl
	call sys_FlashLock
	ld iy,(ix-22)
	ld sp,ix
	pop ix
	ret







