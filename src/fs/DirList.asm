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
.skip_loop_entry:
	ld a,(iy)
	lea iy,iy+16
	or a,a
	jq z,.skip_loop_entry ; skip deleted entry
	inc a
	jq z,.fail ; fail if we're at the end of the directory and still skipping
	inc a
	jq nz,.skip_loop_next_16
	ld hl,(iy+fsentry_filesector-16)
	ld a,l
	and a,h
	inc a
	jq z,.fail ; fail if we're at the end of the directory and still skipping
	push hl
	call fs_GetSectorAddress ; get pointer to next directory section
	ex (sp),hl
	pop iy
	jq .skip_loop_entry
.skip_loop_next_16:
	cp a,fsentry_unlisted+2
	jq z,.skip_loop_entry ; skip unlisted entry
	cp a,fsentry_longfilename+2
	jq nz,.skip_loop      ; entry is not a long file name
	sbc hl,hl
	ld l,(iy-15)
	lea bc,iy
	add hl,bc
	push hl
	pop iy
	jq .skip_loop
.list_loop_entry:
	ld de,0
	ld hl,(ix+6)
	ld bc,(ix+12)
	jq .list_loop_entry_inner
.list_loop:
	lea iy,iy+16
.list_loop_entry_inner:
	ld a,b
	or a,c
	jq z,.endofdir
	ld a,(iy)
	or a,a
	jq z,.list_loop ; skip deleted entry
	inc a
	jq z,.endofdir
	inc a
	jq nz,.list_loop_next_16
	ld hl,(iy+fsentry_filesector-16)
	ld a,l
	and a,h
	inc a
	jq z,.endofdir
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	jq .list_loop
.list_loop_next_16:
	cp a,fsentry_unlisted+2
	jq z,.list_loop
	cp a,fsentry_longfilename+2
	jq nz,.list_loop_append
	push bc
	ld bc,0
	ld c,(iy-15)
	add iy,bc
	pop bc
.list_loop_append:
	ld (hl),iy
	inc hl
	inc hl
	inc hl
	inc de
	dec bc
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

