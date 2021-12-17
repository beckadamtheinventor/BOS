
;@DOES write a byte into a file if the byte can be written
;@INPUT bool fs_WriteByte(uint8_t byte, void *fd, int offset);
;@NOTE Fails if the byte can't be written without swapping
fs_WriteByte:
	call ti._frameset0
	push iy
	ld iy,(ix + 9) ;void *fd
	bit fd_link,(iy+fsentry_fileattr)
	jq nz,.fail
	push iy
	call fs_CheckWritableFD
	dec a
	pop iy
	jq nz,.fail
	ld de, (iy + fsentry_filelen)
	ex.s hl,de
	ld de, (ix + 12)
	or a,a
	sbc hl,de
	jq c,.fail
	push de,iy
	call fs_GetFDPtr
	pop bc,de
	add hl,de
	ex hl,de
	ld c, (ix + 6) ; uint8_t byte
	ld a,(de)
	and a,c
	cp a,c
	jq nz,.fail
.write_byte:
	call sys_FlashUnlock
	ld a,c
	call sys_WriteFlashA
	call sys_FlashLock
.return:
	db $3E
.fail:
	xor a,a
	or a,a
	pop iy,ix
	ret
