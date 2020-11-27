
;@DOES Resizes a file descriptor.
;@INPUT int fs_SetSize(int len, void *fd);
;@OUTPUT number of bytes allocated to the file
;@NOTE Will allocate enough sectors to contain len bytes.
fs_SetSize:
	ld hl,-19
	call ti._frameset
	ld hl,(iy+$C)
	ld (ix-19),hl
	ld iy,(ix+9)
	ld hl,(iy+$E)
	ex.s hl,de
	ld e,0
	res 0,d
	inc d
	inc d
	ld hl,(ix+6)
	or a,a
	sbc hl,de
	add hl,de
	jq c,.update_file_entry ;file resize does not require any more clusters

	ld hl,(ix+6)
	push hl
	call fs_Alloc
	pop bc
	jq c,.fail
	ld (ix-19),hl

	ld hl,(iy+$E)
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
	pop iy,bc,bc
	ld bc,(iy+$C)
	add hl,bc

	pop hl

	call fs_CeilDivBySector
	ld b,l
	ld c,$FF
	push iy
.dealloc_loop:
	push bc,hl
	call sys_WriteFlashByteFull
	pop bc,bc
	djnz .dealloc_loop
	pop iy

.update_file_entry:
	ld bc,16 ;update the file entry
	lea de,ix-16
	lea hl,iy
	push bc
	ldir
	ld bc,(ix+6)
	lea hl,ix-2
	ld (hl),c
	inc hl
	ld (hl),b
	lea hl,ix-4
	ld bc,(ix-19)
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


.allocate_sectors:
	
	jq .update_file_entry






