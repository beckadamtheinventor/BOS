;@DOES list items in a directory
;@INPUT int fs_DirList(void **buffer, const char *path, unsigned int num, unsigned int skip);
;@OUTPUT Returns number of items read. Returns -1 and Cf on fail.
;@NOTE integer arguments "num" and "skip" must be less than 65536.
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
.skip_loop_bypass:
	ld a,(iy)
	or a,a
	jq z,.fail
	inc a
	jq z,.fail
	lea iy,iy+16
	cp a,fsentry_deleted+1
	jq z,.skip_loop_bypass
	cp a,fsentry_unlisted+1
	jq z,.skip_loop_bypass
	jq .skip_loop
.list_loop_entry:
	ld de,0
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
	cp a,fsentry_unlisted+1
	jq z,.list_loop_next
	bit fd_hidden,(iy+fsentry_fileattr)
	jq nz,.list_loop_next
	ld (hl),iy
	inc hl
	inc hl
	inc hl
	inc de
.list_loop_next:
	lea iy,iy+16
	jq .list_loop
.endofdir:
	ld c,0
	ld b,c
	ld (hl),bc
	ex hl,de
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
	pop iy
	pop ix
	ret

