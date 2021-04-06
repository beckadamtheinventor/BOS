;@DOES list items in a directory
;@INPUT void **fs_DirList(void **buffer, const char *path, int num, int skip);
;@OUTPUT pointer to array of dir entry pointers. Returns -1 and Cf on fail
fs_DirList:
	call ti._frameset0
	push iy
	ld hl,(ix+9)
	push hl
	call fs_OpenFile
	pop bc
	jq c,.fail
	ld bc,$B
	add hl,bc
	bit fsbit_subdirectory,(hl)
	jq z,.fail ;fail if not a subdirectory
	inc hl
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	ld bc,(ix+15)
.skip_loop:
	ld a,c
	or a,b
	jq z,.list_loop_entry
	dec bc
.skip_loop_bypass_deleted:
	ld a,(iy)
	or a,a
	jq z,.fail
	inc a
	jq z,.fail
	lea iy,iy+16
	cp a,fsentry_deleted+1
	jq z,.skip_loop_bypass_deleted
	jq .skip_loop
.list_loop_entry:
	ld hl,(ix+6)
	ld bc,(ix+12)
.list_loop:
	ld a,b
	or a,c
	jq z,.endofdir
	dec bc
	ld a,(iy)
	or a,a
	jq z,.endofdir
	inc a
	jq z,.endofdir
	cp a,fsentry_deleted+1
	jq z,.list_loop_next
	bit fd_hidden,(iy+fsentry_fileattr)
	jq nz,.list_loop_next
	ld (hl),iy
	inc hl
	inc hl
	inc hl
.list_loop_next:
	lea iy,iy+16
	jq .list_loop
.endofdir:
	ex hl,de
	or a,a
	sbc hl,hl
	ex hl,de
	ld (hl),de
.done:
	ld hl,(ix+6)
	db $01
.fail:
	scf
	sbc hl,hl
	pop iy
	pop ix
	ret

