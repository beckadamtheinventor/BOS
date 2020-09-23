
;@DOES read a given sector of a file descriptor
;@INPUT void *fs_GetSectorPtr(void *fd, int sector);
;@OUTPUT hl = pointer to sector. hl = -1 if failed.
;@NOTE this does not guarantee a contiguous memory space, as files can be fragmented in FAT32.
fs_GetSectorPtr:
	call ti._frameset0
	ld hl,(ix+6)
	ld de,(ix+9)
.loop:
	ex hl,de
	add hl,de
	or a,a
	sbc hl,de
	ex hl,de
	jr z,.exit
	dec de
	push hl
	ld a,$FF
	ld b,3
.check_end_loop:
	cpi
	jr nz,.next
	djnz .check_end_loop
	ld a,$F0
	cp a,(hl)
.next:
	pop hl
	ld bc,4
	add hl,bc
	jr nz,.loop
	scf
	sbc hl,hl
	ret
.exit:
	ld hl,(hl)
	xor a,a
	ret
