;@DOES write a given data pointer to the swap sector at a given offset
;@INPUT void *sys_ToSwapSector(void *data, int len, int dest_offset);
;@OUTPUT pointer to swap sector
sys_ToSwapSector:
	call ti._frameset0
	ld a,'B'
	call fs_PartitionDescriptor
	ld bc,8
	add hl,bc
	ld hl,(hl)
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	push hl
	ld de,(ix+12)
	add hl,de
	ex hl,de
	ld hl,(ix+6)
	ld bc,(ix+9)
	call sys_WriteFlash
	pop hl
	pop ix
	ret

