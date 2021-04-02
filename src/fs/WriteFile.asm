
;@DOES Overwrite all data stored in a file from a given data pointer.
;@INPUT int WriteFile(void *data, int len, void *fd);
;@OUTPUT number of bytes written. 0 if failed to write
;@NOTE Only the number of clusters aready allocated to the file will be written. Call fs_SetSize() to reallocate file clusters.
fs_WriteFile:
	ld hl,-19
	call ti._frameset
	push iy
	ld iy,(ix+12)
	bit fsbit_readonly,(iy+fsentry_fileattr)
	jq nz,.fail
	ld hl,(ix+9)
	ld bc,65535
	or a,a
	sbc hl,bc
	jq nc,.fail
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	ld hl,(iy+fsentry_filelen)
	ld de,(ix+9)
	ex.s hl,de
	or a,a
	sbc hl,de ;check if write len (hl) <= file length (de)
	jq nc,.length_ok
	ex hl,de ;use file length as write length instead
.length_ok:
	push de
	pop bc
	pop hl
	ld de,(ix+6)
	push bc,de,hl
	call sys_WriteFlashFullRam
	jq c,.fail
	pop bc,bc,bc

.success:
	ld hl,(ix+9)
	db $01
.fail:
	xor a,a
	sbc hl,hl
	pop iy
	ld sp,ix
	pop ix
	ret


