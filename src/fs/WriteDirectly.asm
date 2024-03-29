;@DOES Attempt to write data to a file directly, failing if the data can't be written correctly or if the file isnt large enough.
;@INPUT void *fs_WriteDirectly(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT New file descriptor or -1 and Cf set if failed.
;@DESTROYS All
fs_WriteDirectly:
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
	lea hl,iy
	call fs_GetFDLen.entry
	ex hl,de
	pop hl ; len*count
	push hl
	ld bc, (ix + 18) ; offset
	add hl,bc ; len*count+offset
	or a,a
	inc de
	sbc hl,de
	jq nc,.fail ; fail if offset+len*count > file size
	lea hl,iy
	call fs_GetFDPtr.entry ; get pointer to file data section
	jr c,.fail
	ld bc, (ix + 18) ; offset
	add hl,bc
	ex hl,de
	pop bc ; pop len*count
	ld hl, (ix + 6) ; data
	push de,bc ; save dest and write len
.write_check_loop:
	ld a,(de)
	and a,(hl)
	cp a,(hl)
	jr nz,.fail
	inc de
	inc hl
	dec bc
	ld a,c
	or a,b
	jr nz,.write_check_loop
	call sys_FlashUnlock
	pop bc,de ; restore write len and dest
	ld hl, (ix + 6)
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
