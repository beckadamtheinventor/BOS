
;@DOES write a byte into a file
;@INPUT int fs_WriteByte(uint8_t byte, void *fd, int offset);
fs_WriteByte:
	call ti._frameset0
	ld hl,(ix+9)
	ld bc,fsentry_fileattr
	add hl,bc
	bit fsbit_readonly,(hl)
	jq nz,.fail
	bit fsbit_subfile,(hl)
	inc hl
	ld de,(hl)
	jq z,.get_sector_address
	push hl
	ex.s hl,de
	pop de
	ld e,0
	res 0,d
	add hl,de
	jq .got_file_ptr
.get_sector_address:
	push de
	call fs_GetSectorAddress
	pop bc
.got_file_ptr:
	ld bc,(ix+12)
	add hl,bc
	ld c,(ix+6)
	push bc,hl
	call sys_WriteFlashByteFullRam
	pop hl,bc
	or a,a
	sbc hl,hl
	ld l,c
	db $01
.fail:
	scf
	sbc hl,hl
	pop ix
	ret
