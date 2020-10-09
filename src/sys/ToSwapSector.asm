;@DOES write a given data pointer to the swap sector at a given offset
;@INPUT void *sys_ToSwapSector(int dest_offset, void *data, int len);
;@OUTPUT pointer to swap sector
sys_ToSwapSector:
	call ti._frameset0
	ld a,'B'
	call fs_DrivePtr
	push hl
	ld de,(ix+6)
	add hl,de
	ex hl,de
	ld hl,(ix+9)
	ld bc,(ix+12)
	call sys_WriteFlash
	pop hl
	pop ix
	ret

