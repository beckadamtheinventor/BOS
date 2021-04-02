
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
	ld a,l
	or a,h
	jq nz,.allocate_from_nonempty_file

	ld hl,(ix+6)
	push hl
	call fs_Alloc ;allocate space for new file
	jq c,.fail
	pop bc
	ld (ix-19),hl
	jq .update_file_entry

.allocate_from_nonempty_file:
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	ld de,(ix+6)
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.update_file_entry ;file resize does not require any more clusters

	push iy
	call fs_Free ;free the old file clusters
	pop iy

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
	call sys_WriteFlashFullRam
	pop bc,bc,bc

.update_file_entry:
	ld iy,(ix+9)
	lea de,ix-16
	lea hl,iy
	ld bc,16
	push bc
	ld c,12
	ldir
	ld bc,(ix-19)
	ld (ix-4),bc
	ld bc,(ix+6)
	ld (ix-2),c
	ld (ix-1),b
	pea ix-16
	push iy
	call sys_WriteFlashFullRam
	pop bc,bc,bc

.success:
	db $3E
.fail:
	xor a,a
	or a,a
	ld sp,ix
	pop ix
	ret

.cluster_file:
	db "/dev/cmap.dat",0







