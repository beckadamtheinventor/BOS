
;@DOES Create and write a new file
;@INPUT void *fs_WriteNewFile(const char *name, uint8_t properties, void *data, int len);
;@OUTPUT file descriptor
fs_WriteNewFile:
	ld hl,-22
	call ti._frameset
	ld hl,(ix+6)
	ld e,(ix+9)
	ld bc,(ix+15)
	push bc,de,hl
	call fs_CreateFile
	jq c,.fail
	pop bc,bc,bc
	ld bc,0
	push bc,hl
	ld c,1
	push bc
	ld bc,(ix+15)
	push bc
	ld bc,(ix+12)
	push bc
	call fs_Write
	jq c,.fail
	pop bc,bc,bc,hl,bc
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

