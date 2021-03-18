
;TODO
updater_walk.next:
	lea iy,iy+16
updater_walk:
	ld a,(iy)
	or a,a
	ret z
	cp a,'.'
	jq z,.next
	bit f_subdir,(iy+fsentry_fileattr)
	jq nz,.subdir
	ld hl,.temparea
	push iy,hl
	call fs_CopyFileName
	call fs_OpenFile
	pop bc,iy
	jq nc,.write

	ld de,(iy+fsentry_fileattr)
	push iy,de,bc
	call fs_CreateFile
	pop bc,de,iy
	jq c,.next

.write:
	ld bc,(iy+fsentry_filesector)
	push bc
	call fs_GetSectorAddress
	pop bc
	ld bc,$D10000 - $040000
	add hl,bc
	ld bc,0
	ld c,(iy+fsentry_filelen)
	ld b,(iy+fsentry_filelen+1)
	push hl,iy,bc
	call fs_SetSize
	pop bc,iy,hl
	push iy,bc,hl
	call fs_WriteFile
	pop hl,bc,iy
	jq .next

.subdir:
	ld bc,(iy+fsentry_filesector)
	push bc
	call fs_GetSectorAddress
	ex (sp),iy
	call updater_walk
	pop iy
	jq .next

