
;@DOES Create and write a new file
;@INPUT void *fs_WriteNewFile(const char *name, uint8_t properties, void *data, int len);
;@OUTPUT HL = file descriptor. HL = -1 and Cf set if failed.
fs_WriteNewFile:
	call ti._frameset0
	ld hl,(ix+6)
	ld e,(ix+9)
	ld bc,(ix+15)
	push bc,de,hl
	call fs_CreateFile
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail
	pop bc,bc,bc
	call fs_GetFDPtr.entry
	ex hl,de
	ld hl,(ix+12)
	ld bc,(ix+15)
	call sys_FlashUnlock
	call sys_WriteFlash
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
	call sys_FlashLock
	ld sp,ix
	pop ix
	ret

