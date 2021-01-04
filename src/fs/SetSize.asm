
;@DOES Resizes a file descriptor.
;@INPUT bool fs_SetSize(int len, void *fd);
;@OUTPUT true if resizing succeeded
;@NOTE Will allocate enough sectors to contain len bytes.
fs_SetSize:
	ld hl,-19
	call ti._frameset
	ld iy,(ix+9)
	ld hl,(iy+$C)
	ld (ix-19),hl
	ld de,(iy+$E)
	ex.s hl,de
	call fs_CeilDivBySector
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	ld de,(ix+6)
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.update_file_entry ;file resize does not require any more clusters

	ld hl,(iy+$E)
	ex.s hl,de
	push de
	ld hl,(ix+6)
	push hl
	call fs_Alloc ;allocate space for new file
	jq c,.fail
	pop bc
	ld (ix-19),hl
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	ld hl,(iy+$C)
	push hl
	call fs_GetSectorAddress
	pop bc
	ex (sp),hl
	push hl
	call sys_WriteFlashFull
	pop bc,bc,bc

	ld de,(iy+$E)
	ex.s hl,de
	call fs_CeilDivBySector
	push hl
	ld hl,.cluster_file
	push hl
	call fs_OpenFile
	pop bc
	ld bc,$C
	add hl,bc
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	push hl
	ld iy,(ix+9)
	ld de,(iy+$C) ;file's old address
	ex.s hl,de
	pop de
	pop bc
	add hl,de ;hl = &cluster_table[file_old_address];
	ex hl,de
	ld hl,$03FF80 ;should always read 128 bytes of 0xFF
	push bc,hl,de
	call sys_WriteFlashFull
	pop bc,bc,bc
	ld iy,(ix+9)

.update_file_entry:
	lea de,ix-16
	lea hl,iy
	ld bc,16
	push bc
	ld c,12
	ldir
	lea hl,ix-4
	ld bc,(ix-19)
	ld (hl),bc
	inc hl
	inc hl
	ld bc,(ix+6)
	ld (hl),c
	inc hl
	ld (hl),b
	pea ix-16
	push iy
	call sys_WriteFlashFull
	pop bc,bc,bc

.success:
	db $3E
.fail:
	xor a,a
	ld sp,ix
	pop ix
	ret

.cluster_file:
	db "/dev/cmap.dat",0







