;@DOES write data to a file
;@INPUT void *fs_Write(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT New file descriptor or -1 and Cf set if failed.
;@DESTROYS All
fs_Write:
	ld hl,-12
	call ti._frameset
	ld (ix-6),iy
	ld bc,(ix+15) ;void *fd
	push bc
	call fs_CheckWritableFD
	dec a
	jq nz,.fail
	pop iy
	ld de,(ix+9) ;int len
	ld b,(ix+12) ;uint8_t count
	or a,a
	sbc hl,hl
.mult_loop:
	add hl,de
	djnz .mult_loop
	ld (ix-3),hl
	ld de,(ix+18) ;int offset
	add hl,de
	ld bc,65535
	or a,a
	sbc hl,bc
	jq nc,.fail ;check if write length + write offset > 65535
	add hl,bc
	ld (ix-12),hl
	ld bc,(ix+15) ; void *fd
	ld (ix-9),bc
	push bc,hl
	call fs_SetSize
	jq c,.fail
	ld (ix+15),hl
	pop bc,bc

	push hl
	call sys_FlashUnlock
	call fs_GetFDPtr ; get pointer to new file data section
	push hl
	ld hl,(ix-9)
	push hl
	call fs_GetFDPtr ; get pointer to old file data section
	pop bc,de,bc
	push de,hl
	ld bc,(ix+18) ; int offset
	ld a,b
	or a,c
	call nz,sys_WriteFlash
	ld bc,(ix-3) ; len*count
	ld hl,(ix+6) ; void *data
	ld a,b
	or a,c
	call nz,sys_WriteFlash
	ld hl,(ix+18)
	ld bc,(ix-3)
	add hl,bc
	ld bc,(ix-12) ; new file length
	or a,a
	sbc hl,bc
	jq nc,.done ; we're done if write offset + write length >= end of file
	add hl,bc
; otherwise write the trailing bytes
	pop de
	add hl,de ; &old_data[offset + len*count]
	ex hl,de ; exchange old data offset and offset+len*count
	pop bc
	push hl ; save offset+len*count
	add hl,bc ; &new_data[offset + len*count]
	pop bc ; restore offset+len*count
	push hl ; save &new_data[offset + len*count]
	ld hl,(ix-12) ; new file length
	or a,a
	sbc hl,bc ; eof - (offset+len*count)
	ld c,l ; load low 16 bits of hl into bc, assume bcu is 0
	ld b,h
	pop hl
	ex hl,de
	; hl = old_data, de = new_data, bc = new_len - (offset + len*count)
	ld a,c
	or a,b
	call nz,sys_WriteFlash

	; no need to free the old data section because it was already freed in fs_SetSize
.done:
	ld hl,(ix+15)
	or a,a
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl

	call sys_FlashLock
	ld iy,(ix-6)
	ld sp,ix
	pop ix
	ret

