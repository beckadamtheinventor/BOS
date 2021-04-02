
;@DOES write a byte into a file
;@INPUT int fs_WriteByte(uint8_t byte, void *fd, int offset);
fs_WriteByte:
	call ti._frameset0
	ld hl,(ix+9)
	ld bc,$B
	add hl,bc
	bit f_readonly,(hl)
	jq nz,.fail
	inc hl
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
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
