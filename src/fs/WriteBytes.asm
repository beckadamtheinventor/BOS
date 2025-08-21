;@DOES Fill a file with a given byte.
;@INPUT bool fs_WriteBytes(uint8_t byte, void *fd, unsigned int count);
fs_WriteBytes:
    ld hl,-6
	call ti._frameset
	push iy
	ld iy,(ix + 9) ;void *fd
	bit fd_link,(iy+fsentry_fileattr)
    pop iy
	jq nz,.fail
	; push iy
	; call fs_CheckWritableFD
	; dec a
	; pop iy
	; jq nz,.fail
    call .grab_len_and_ptr
    ld hl,(ix+12) ; count
    scf
    sbc hl,bc ; count - len
    jr nc,.relocate_file ; relocate the file if the count > len
    ld hl,(ix-3) ; ptr
    ; ld bc,(ix-6) ; len
.checkloop:
    ld a,(ix+6) ; byte
    and a,(hl) ; check against existing byte in flash
    cp a,(ix+6) ; check against desired byte
    jr nz,.relocate_file ; if (existing & new) != new, we need to relocate the file.
    cpi
    jp pe,.checkloop
.no_relocate:
    call sys_FlashUnlock
    ld de,(ix-3) ; pointer
    ld bc,(ix-6) ; number of bytes to write
.writeloop:
    ld a,(ix+6) ; byte to write
    call sys_WriteFlashA
    inc de
    cpi ; bc--, PO set if bc decrements to zero
    jp pe,.writeloop
    call sys_FlashLock
    jr .return
.relocate_file:
    ld hl,(ix+9) ; fd
    push hl
    ld hl,(ix-6) ; len
    push hl
    call fs_SetSize ; re-allocate the file somewhere else
    jr c,.fail
    ld (ix+9),hl ; new file descriptor
    pop bc,bc
    call .grab_len_and_ptr
    jr .no_relocate
.return:
	db $F6 ; or a,... unset carry flag
.fail:
	xor a,a
    ld sp,ix
	pop ix
	ret

.grab_len_and_ptr:
    ld hl,(ix+9)
    push hl ; save fd
    call fs_GetFDPtr.entry
    ld (ix-3),hl
    ex (sp),hl ; save pointer, restore fd
    call fs_GetFDLen.entry
    ld (ix-6),hl
    ex (sp),hl ; save length, restore pointer
    pop bc
    ret
