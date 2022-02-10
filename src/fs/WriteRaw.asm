;@DOES Attempt to write data to a file directly, failing if the data can't be written correctly or if the file isnt large enough.
;@INPUT void *fs_WriteRaw(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT New file descriptor or -1 and Cf set if failed.
;@DESTROYS All
fs_WriteRaw:
	ld hl,-3
	call ti._frameset
	ld (ix-3),iy
	ld iy,(ix+15) ;void *fd
	bit fd_link,(iy+fsentry_fileattr)
	jq nz,.fail
	; push iy
	; call fs_CheckWritableFD
	; dec a
	; jq nz,.fail
	; pop iy
	or a,a
	sbc hl,hl
	ld de, (ix + 9) ; len
	ld b, (ix + 12) ; count
.countloop:
	add hl,de
	djnz .countloop
	ld a,l
	or a,h
	jq z,.return
	push hl
	ex hl,de
	ld hl, (iy + fsentry_filelen)
	ex.s hl,de
	ld bc, (ix + 18) ; offset
	add hl,bc ; len*count+offset
	or a,a
	inc de
	sbc hl,de
	jq nc,.fail ; fail if offset+len*count > file size
	push iy
	call fs_GetFDPtr ; get pointer to file data section
	ld bc, (ix + 18) ; offset
	add hl,bc
	ex hl,de
	pop bc,bc ; pop file descriptor, len*count
	ld hl, (ix + 6) ; data
	push de,bc ; save dest and write len
.write_check_loop:
	ld a,(de)
	and a,(hl)
	cp a,(hl)
	jq nz,.fail
	inc de
	inc hl
	dec bc
	ld a,c
	or a,b
	jq nz,.write_check_loop
	call sys_FlashUnlock
	pop bc,de ; restore write len and dest
	ld hl, (ix+6)
	call sys_WriteFlash ; write the data
	call sys_FlashLock
.return:
	ld hl,(ix + 15) ; return the file descriptor
	db $01
.fail:
	scf
	sbc hl,hl
	or a,a
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret
