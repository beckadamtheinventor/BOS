
;@DOES Create and write a new file
;@INPUT void *fs_WriteNewFile(const char *name, uint8_t properties, void *data, int len);
;@OUTPUT HL = file descriptor. HL = -1 and Cf set if failed.
;@NOTE Will overwrite file if it exists.
fs_WriteNewFile:
	call ti._frameset0
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	jr nc,.write
	pop bc
	ld e,(ix+9)
	ld hl,(ix+15)
	push hl,de,bc
	call fs_CreateFile
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail
	pop bc,bc,bc
.write:
	ld bc,(ix+15)
	ld de,(ix+12)
	push hl,bc,de
	call fs_WriteFile
	; pop bc,bc,bc ; unneccary as long as we load the stack pointer when exiting
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

