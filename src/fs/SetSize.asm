
;@DOES Resizes a file descriptor.
;@INPUT void *fs_SetSize(int len, void *fd);
;@OUTPUT new file descriptor if success, -1 and Cf set if fail
;@NOTE New file contents will be empty, but old file data will be preserved until the next cleanup.
fs_SetSize:
	ld hl,-22
	call ti._frameset
	ld (ix-3),iy
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
    push iy ; pointer to old file descriptor

    ld hl,(ix+6) ; int len
    add hl,bc
    or a,a
    sbc hl,bc
    ld bc,$FFFF
    ld (ix-9),hl ; new file length
    ld (ix-12),bc ; new file sector
    jr z,.alloc_zero_space
    ld (ix-12),hl
    push hl
    call fs_Alloc ; allocate space for new file
    pop bc
    jr c,.fail
    ld (ix-12),hl ; new file sector
.alloc_zero_space:

    call fs_CopyFileName
    pop iy
    ld c,(iy+fsentry_fileattr)
    push bc
    push hl
    call fs_CreateFileEntry.dontfail ; create new file descriptor
    ex (sp),hl
    call sys_Free.entryhl ; free copied file name
    pop hl ; new file descriptor
    pop bc
    ld (ix-6),hl ; new file descriptor
    ld a,c
    ld de,fsentry_fileattr
    add hl,de
    ex hl,de
    call sys_FlashUnlock
    call sys_WriteFlashA ; increments de
    ; move file length back 2 bytes so we can make this only one flash write call
    ld hl,(ix-9)
    ld (ix-10),hl
    lea hl,ix-12
    ld bc,4
    call sys_WriteFlash
    ; delete old file descriptor
    ld de,(ix+9)
    xor a,a
    call sys_WriteFlashA
    ld hl,(ix-6)
.success:
	db $01
.fail:
	scf
	sbc hl,hl
	call sys_FlashLock
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret
