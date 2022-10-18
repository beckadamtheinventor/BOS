
;@DOES Resizes a file descriptor.
;@INPUT void *fs_SetSize(int len, void *fd);
;@OUTPUT new file descriptor if success, -1 and Cf set if fail
;@NOTE New file contents will be empty, but old file data will be preserved until the next cleanup.
fs_SetSize:
	ld hl,-22
	call ti._frameset
	ld (ix-22),iy
	ld iy,(ix+9) ;void *fd
	bit fd_link,(iy+fsentry_fileattr)
	jq nz,.fail
	; push iy
	; call fs_CheckWritableFD
	; dec a
	; jq nz,.fail
	; pop hl
	; ld bc,fsentry_filelen
	; add hl,bc
	; ld hl,(hl)
	; ex.s hl,de
	; ld hl,(ix+6)
	; or a,a
	; sbc hl,de
	; jq z,.success
	ld hl,(ix+9) ; pointer to old file descriptor
	lea de,ix-16
	ld bc,fsentry_fileattr+1
	ldir ; copy old descriptor into ram
	ld hl,(ix+9)
	call fs_AllocDescriptor.entry ; allocate a new file descriptor
	jr c,.fail
	ld (ix-19),hl

	ld iy,(ix+9)
	bit fd_subfile, (iy+fsentry_fileattr)
	lea hl,iy
	call z,fs_Free.entryhl ;free the old file if not a subfile

	ld hl,(ix+6)
	push hl
	call fs_Alloc
	jr c,.fail
	ld (ix + fsentry_filesector - 16), hl ; set new file descriptor data pointer
	pop hl
	ld (ix + fsentry_filelen+0 - 16),l ; set new file descriptor data length
	ld (ix + fsentry_filelen+1 - 16),h
	call sys_FlashUnlock
	ld de,(ix+9)
	xor a,a
	call sys_WriteFlashA ; delete the old file descriptor

	ld de,(ix-19)
	push de
	lea hl,ix-16
	ld bc,fs_file_desc_size
	call sys_WriteFlash ; write the new file descriptor
	pop hl
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
