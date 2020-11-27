;@DOES write data to a file
;@INPUT int fs_Write(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT Returns -1 if failed to write
;@DESTROYS All. Assume OP5, OP6
;@NOTE file must be at least offset + len * count bytes in size.
fs_Write:
	ld hl,-6
	call ti._frameset
	ld (ix-3),iy
	ld iy,(ix+15) ;void *fd
	ld de,(ix+9) ;int len
	ld b,(ix+12) ;uint8_t count
	or a,a
	sbc hl,hl
.mult_loop:
	add hl,de
	djnz .mult_loop
	ld (ix-6),hl
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

	ld hl,(iy+$C) ;file first sector
	push hl
	call fs_GetSectorAddress
	pop bc
	ld bc,(ix-6)
	ld de,(ix+6)
	push bc,de,hl
	call sys_WriteFlashFull
	pop bc,bc,bc
	
	ld hl,(ix-6)
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl

	ld sp,ix
	pop ix
	ret

