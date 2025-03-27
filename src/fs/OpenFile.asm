
;@DOES Opens a file from a path and returns file descriptor.
;@INPUT void *fs_OpenFile(char *path);
;@OUTPUT hl = file descriptor. hl is -1 and Cf set if file does not exist.
;@DESTROYS All
fs_OpenFile:
	pop bc,hl
	push hl,bc
.entryhl:
	ld a,(hl)
	cp a,' '
	jq z,.pathzero
	or a,a
	jq nz,.pathnonzero
.pathzero:
	scf
	sbc hl,hl
	ret
.pathnonzero:
	ld hl,-18
	call ti._frameset
	ld (ix-15),iy
	or a,a
	sbc hl,hl ; set it to null if it's the same pointer as the input path i.e. the path is already an absolute path
	ld (ix-18),hl ; save pointer to path so we can free it later
	ld hl,(ix+6)
	push hl
	call fs_AbsPath
	pop bc
	jq c,.fail
	or a,a
	sbc hl,bc
	add hl,bc
	jr z,.dont_set_mallocd_path
	ld (ix-18),hl ; save pointer to path so we can free it later
.dont_set_mallocd_path:
	ld iy,start_of_user_archive
	inc hl
	ld a,(hl)
	or a,a
	jq z,._return
	ld (ix-3),hl
	ld hl,(iy + fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
.entry:
.main_search_loop:
	ld hl,(ix-3)
	ld (ix-12),hl
	ld a,(hl)
	or a,a
	jq z,.return
	cp a,' '
	jq z,.return
	cp a,':'
	jq z,.return
	cp a,$A
	jq z,.return
	push hl
	call fs_PathLen
	ld (ix-9),hl
	ex (sp),hl
	pop bc
	ld a,'/'
	cpir         ;get next path string
	jq nz,.no_more_slash ;no more '/' found
	push bc
	dec hl
.next_path_skip_slash_loop:
	cpi
	jq z,.next_path_skip_slash_loop
	pop bc
	inc bc
	dec hl
.no_more_slash:
	ld (ix-3),hl ;advance path entry
	ld hl,(ix-9)
	or a,a
	sbc hl,bc ;how long was the string?
	ld (ix-9),hl
	call .search_loop ;returns Zf if failed
	jq z,.fail
	ld hl,(ix-3)
	ld a,(hl)
	or a,a
	jq z,._return ;return if at end of string
	cp a,' '
	jq z,._return ;return if at end of path
	cp a,':'
	jq z,._return ;return if at end of path
	cp a,$A
	jq z,._return ;return if at end of path
.into_dir:
	bit fd_subdir,(iy + fsentry_fileattr) ;check if we're entering a directory
	jq z,.fail ;trying to path into a file?
.step_into_dir:
	push iy
	call fs_GetFDPtr
	ex (sp),hl
	pop iy
	jq .main_search_loop
.return:
	xor a,a
	jq ._return
.fail:
	scf
	sbc hl,hl
	db $01 ;ld bc,...
._return:
	lea hl,iy ;is a 3 byte instruction
	ld iy,(ix-15) ;restore iy

	push af,hl
	ld hl,(ix-18)
	call sys_Free.entryhl
	pop hl,af

	ld sp,ix
	pop ix
	ret


.search_next_section:
	ld hl,(iy+fsentry_filesector)
	ld a,l
	and a,h
	inc a
	jr nz,.next_section_has_address
	inc a
	ret
.next_section_has_address:
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
.search_next:
	ld hl,(ix-6)
	call sys_Free.entryhl ; free the memory malloc'd by fs_CopyFileName
	lea iy,iy+fs_file_desc_size
;searches for a file name in a directory listing
.search_loop:
	ld a,(iy)
	inc a
	ret z ; reached end of directory
	inc a
	jr z,.search_next_section ; reached end of directory section
	; cp a,fsentry_longfilename+2
	push iy
	; ld hl,(iy+1)
	call fs_CopyFileName ;get file name string from file entry
	ld (ix-6),hl
	push hl
	call ti._strlen ;get length of file name string from file entry
	ld bc,(ix-9) ;compare lengths
	or a,a
	sbc hl,bc
	add hl,bc
	pop bc,iy
	jq nz,.search_next
	push iy,hl,bc
	ld bc,(ix-12)
	push bc
	call ti._strncmp ; compare with the target directory if the lengths are the same
	pop bc,bc,bc,iy
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,.search_next ;check next file entry
	ld hl,(ix-6)
	call sys_Free.entryhl ; free the memory malloc'd by fs_CopyFileName
	xor a,a
	inc a
	ret
