;@DOES write data to a file
;@INPUT int fs_Write(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT Returns -1 and Cf set if failed to write
;@DESTROYS All. Assume OP5, OP6
;@NOTE file must be at least offset + len * count bytes in size.
fs_Write:
	ld hl,-6
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
	push hl
	ld hl,(iy+$E) ;file length
	ex.s hl,de
	pop hl
	or a,a
	inc de
	sbc hl,de
	jq nc,.fail ;check if write length + write offset > file length
	add hl,de
	ld de,65535
	or a,a
	sbc hl,de
	jq nc,.fail ;check if write length + write offset > 65535
	add hl,de

	bit fsbit_subfile,(iy + fsentry_fileattr)
	ld de,(iy + fsentry_filesector) ;file first sector
	jq z,.get_sector_ptr
	ex.s hl,de
	lea de,iy
	ld e,0
	res 0,d
	add hl,de
	jq .got_file_ptr
.get_sector_ptr:
	push de
	call fs_GetSectorAddress
	pop bc
.got_file_ptr:
	ld bc,(ix+18)
	add hl,bc
	ld bc,(ix-3)
	ld de,(ix+6)
	push bc,de,hl
	call sys_WriteFlashFullRam
	pop bc,bc,bc
	
	ld hl,(ix-3)
	or a,a
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl

	ld iy,(ix-6)
	ld sp,ix
	pop ix
	ret

