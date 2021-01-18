;@DOES read data from a file into RAM
;@INPUT int fs_Read(void *dest, int len, uint8_t count, void *fd, int offset);
;@OUTPUT number of bytes read
;@DESTROYS All
fs_Read:
	ld hl,-3
	call ti._frameset
	ld hl,(ix+15)
	ld bc,fsentry_filesector
	add hl,bc
	call _LoadDEInd_s
	ld (ix-3),de
	ld c,fsentry_filelen - fsentry_filesector
	add hl,bc
	call _LoadDEInd_s
	push de
	ld de,(ix+9)
	ld b,(ix+12)
	or a,a
	sbc hl,hl
.mult_loop:
	add hl,de
	djnz .mult_loop
	push hl
	pop bc
	ld de,(ix+18)
	add hl,de
	pop de
	add hl,de
	or a,a
	sbc hl,de
	jq c,.fail
	
	ld hl,(ix-3)
	push bc,hl
	call fs_GetSectorAddress
	ld bc,(ix+18)
	add hl,bc
	pop bc,bc
	ld de,(ix+6)
	ld (ScrapMem),bc
	ld a,(ScrapMem+2)
	or a,c
	or a,b
	push bc
	jq z,.zero_copy_len
	ldir
.zero_copy_len:
	pop hl
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
.return:
	ld sp,ix
	pop ix
	ret
