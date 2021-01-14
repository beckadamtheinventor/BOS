;@DOES list items in a directory
;@INPUT void **fs_DirList(void **buffer, const char *path, int num, int skip);
;@OUTPUT pointer to array of dir entry pointers. Returns -1 and Cf on fail
fs_DirList:
	call ti._frameset0
	ld hl,(ix+9)
	push hl
	call fs_OpenFile
	ex (sp),hl
	pop iy
	bit f_subdir, (iy+fsentry_fileattr)
	jq z,.fail
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	ld hl,(ix+15)
	ld de,(ix+12)
	ld bc,1
.skip_loop:
	or a,a
	sbc hl,bc
	jq c,.list_loop_entry
	ld a,(iy)
	lea iy,iy+16
	or a,a
	jq z,.fail
	cp a,fsentry_deleted
	jq nz,.skip_loop
	add hl,bc
	jq .skip_loop
.list_loop_entry:
	ex hl,de
	ld de,(ix+6)
.list_loop:
	or a,a
	sbc hl,bc
	jq c,.done
	ld a,(iy)
	or a,a
	jq z,.done
	cp a,fsentry_deleted
	jq z,.list_loop_skip_deleted
	ex hl,de
	ld (hl),iy
	inc hl
	inc hl
	inc hl
	ex hl,de
	lea iy,iy+16
	jq .list_loop
.list_loop_skip_deleted:
	lea iy,iy+16
	add hl,bc
	jq .list_loop
.done:
	ld hl,(ix+6)
	db $01
.fail:
	scf
	sbc hl,hl
	pop ix
	ret

