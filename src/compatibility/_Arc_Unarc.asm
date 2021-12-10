
_Arc_Unarc:
	ld hl,-4
	call ti._frameset
	call _OP1ToPath
	ld de,str_tivars_dir
	push hl,de
	call fs_JoinPath
	ld (ix-3),hl
	pop bc
	call sys_Free
	ld hl,(ix-3)
	ex (sp),hl
	call fs_GetFilePtr
	ld de,$D00000
	or a,a
	sbc hl,de
	add hl,de
	jq nc,.toarchive
	inc hl
	dec bc
	push hl,bc,bc
	pop hl
	ld de,(top_of_UserMem)
	push de
	call _InsertMem
	pop hl,bc,de
	sbc a,a
	jq c,.done
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	push bc,hl
	ex hl,de
	ldir
	ld hl,(ix-3)
	ld c,0
	push bc,hl
	call fs_CreateRamFile
	pop bc
	sbc a,a
	ld (ix-4),a
	call sys_Free
	pop bc,bc,bc
	ld a,(ix-4)
.done:
	ld sp,ix
	pop ix
	or a,a
	ret z
	jq _ErrMemory

.toarchive:
	push iy
	inc bc
	push hl,bc
	ld c,0
	ld hl,(ix-3)
	push bc,hl
	call fs_CreateFile
	pop bc,bc
	ld bc,0
	push bc,hl
	inc c
	push bc
	call fs_WriteByte ; write header byte into the file
	pop bc,hl,bc,de,iy
	ld bc,1
	push bc,hl,bc,de,iy
	call fs_Write ; write var length and file data
	sbc a,a
	jq .done
