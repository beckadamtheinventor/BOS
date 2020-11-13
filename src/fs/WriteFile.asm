
;@DOES Overwrite all data stored in a file from a given data pointer.
;@INPUT int WriteFile(void *data, int len, void *fd);
;@OUTPUT number of bytes written. 0 if failed to write
;@NOTE Only the number of clusters aready allocated to the file will be written. Call fs_SetSize() to reallocate file clusters.
fs_WriteFile:
	ld hl,-19
	call ti._frameset
	ld hl,(ix+9)
	ld bc,65535
	or a,a
	sbc hl,bc
	jq nc,.fail
	ld iy,(ix+12)
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld de,(ix+9) ;compare target length with existing length
	or a,a
	sbc hl,de
	jq c,.alloc
	add hl,de
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	pop bc
	ld de,(ix+6)
	ld bc,(ix+9)
	push bc,de,hl
	call sys_WriteFlashFull
	jq c,.fail
	pop bc,bc,bc

.success:
	ld hl,(ix+9)
	db $01
.fail:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

.alloc:
	ld hl,(iy+fsentry_filesector)
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	push de
	call fs_CeilDivBySector
	push hl
	ld hl,fs_Alloc.cluster_file
	push hl
	call fs_OpenFile
	pop bc
	add hl,bc
	pop bc
	ld de,$03E000 ;should always read $FF
	push bc,de,hl
	call sys_WriteFlashFull
	pop hl,de,bc

	ld hl,(ix+9)
	push hl
	call fs_Alloc
	jq c,.fail
	pop bc
	call fs_CeilDivBySector
	ld (ix-19),hl
	ld hl,(ix+12)
	lea de,ix-16
	ld bc,16
	push bc,de,hl
	push de
	ldir
	pop hl
	ld bc,$C
	add hl,bc
	ld bc,(ix-19)
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	ld bc,(ix+9)
	ld (hl),c
	inc hl
	ld (hl),b
	call sys_WriteFlashFull
	jq .success


