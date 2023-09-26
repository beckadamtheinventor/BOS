;@DOES write data to a file
;@INPUT void *fs_Write(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT New file descriptor or -1 and Cf set if failed.
;@DESTROYS All
fs_Write:
	ld hl,-13
	call ti._frameset
	ld (ix-6),iy
	ld iy,(ix+15) ;void *fd
	ld a,(ix+15+2)
	cp a,$D0
	jq nc,.write_to_ram_file
	sub a,$40
	jq nc,.write_to_device_fs
.find_file_in_link:
	ld a,(iy)
	inc a
	jq z,.fail ; fail if file linked to is deleted or non-existent
	dec a
	jq z,.fail ; fail if file linked to is deleted or non-existent
	bit fd_link,(iy+fsentry_fileattr)
	jr z,.found_file_in_link
	ld hl,(iy+fsentry_filesector)
	call fs_GetSectorAddress.entry
	push hl
	pop iy
	jr .find_file_in_link
.found_file_in_link:
	; push iy
	; call fs_CheckWritableFD
	; dec a
	; jq nz,.fail
	; pop iy
	ld de,(ix+9) ;int len
	ld b,(ix+12) ;uint8_t count
	or a,a
	sbc hl,hl
.mult_loop:
	add hl,de
	djnz .mult_loop
	ld a,l
	or a,h
	jq z,.done ; do nothing if write length is 0
	ld (ix-3),hl
	ld de,(ix+18) ;int offset
	add hl,de
	ld bc,65535
	or a,a
	sbc hl,bc
	jq nc,.fail ; fail if write length + write offset > 65535
	add hl,bc
	ld (ix-12),hl
	ld bc,(ix+15) ; void *fd
	push bc,hl,bc
	call fs_GetFDPtr ; get pointer to old file data section prior to clobbering it
	jq c,.fail ; fail if we couldn't get a pointer to the file data section
	pop bc
	ld (ix-9),hl
	ld bc,(ix+18) ; int offset
	add hl,bc
	ex hl,de
	ld bc,(ix-3) ; write length (len*count)
	ld hl,(ix+6) ; void *data
	push de ; save pointer to write location
	call sys_FlashUnlock
.check_write_loop: ; check if we can write to the file successfuly without relocating it
	ld a,(de)
	and a,(hl)
	cp a,(hl)
	jr nz,.write_needs_file_moved
	inc de
	cpi
	jp pe,.check_write_loop
	pop de,bc,bc ; pop pointer to write location, discard arguments otherwise for fs_SetSize
	jr .write_data
.write_needs_file_moved:
	pop bc
	call fs_SetSize
	jq c,.fail
	ld (ix+15),hl
	pop bc,bc

	push hl
	call fs_GetFDPtr ; get pointer to new file data section
	pop bc
	ex hl,de
	ld hl,(ix-9) ; get pointer to old file data section
	push de,hl
	ld bc,(ix+18) ; int offset
	ld a,b
	or a,c
	call nz,sys_WriteFlash
.write_data:
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
.donereturnhl:
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

.write_to_ram_file:=.fail
	
	; jq .done

.write_to_device_fs:
	cp a,open_device_table.len / 4
	jq nc,.fail
	add a,a
	add a,a
	sbc hl,hl
	ld l,a
	ld de,open_device_table
	add hl,de
	ld a,(hl)
	dec a
	jq nz,.fail
	inc hl
	ld hl,(hl)
	call fs_GetFDPtrRaw.entry
	push hl
	pop iy
	bit bDeviceFsWriteable,(iy+device_FilesystemDeviceFlags)
	jq z,.fail ; fail if the device filesystem isn't writeable
	lea hl,iy+device_JumpWrite
	ld de,(ix+15)
	ld c,(ix+12)
	push de,bc
	ld de,(ix+9)
	ld bc,(ix+6)
	push de,bc
	call sys_jphl
	pop bc,bc,bc,bc
	jq c,.fail
	jq .donereturnhl
