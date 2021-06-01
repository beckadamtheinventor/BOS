
;@DOES Opens a file from a path and returns file descriptor.
;@INPUT void *fs_OpenFile(char *path);
;@OUTPUT hl = file descriptor. hl is -1 and Cf set if file does not exist.
;@DESTROYS All
;@NOTE This only searches for short 8.3 file names.
fs_OpenFile:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	cp a,' '
	jq z,.pathzero
	or a,a
	jq nz,.pathnonzero
.pathzero:
	ld hl,fs_filesystem_address
	ret ;return root directory
.pathnonzero:
	ld hl,-26
	call ti._frameset
	ld (ix-20),iy
	ld hl,(ix+6)
	push hl
	call fs_AbsPath
	pop bc
	inc hl
	ld (ix-3),hl
	ld iy,fs_filesystem_root_address
	ld a,(hl)
	or a,a
	jq z,.return
	ld iy,fs_filesystem_address
.entry:
.main_search_loop:
	ld hl,(ix-3)
	ld (ix-26),hl
	ld a,(hl)
	or a,a
	jq z,.return
	push hl
	call ti._strlen
	ld (ix-23),hl
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
	ld a,(hl)
	cp a,'$'
	jq z,.return_file_entry_point
	ld hl,(ix-23)
	or a,a
	sbc hl,bc ;how long was the string?
	ld (ix-23),hl
	call .search_loop ;returns Zf if failed
	jq z,.fail
	ld hl,(ix-3)
	ld a,(hl)
	or a,a
	jq z,._return
.into_dir:
	bit fsbit_subdirectory,(iy + fsentry_fileattr) ;check if we're entering a directory
	jq z,.fail ;trying to path into a file?
.step_into_dir:
	bit fsbit_subfile,(iy + fsentry_fileattr) ;check if we're pathing into a subfile
	ld de,(iy + fsentry_filesector) ;load file entry starting sector into de
	jq z,.step_into_regular_dir ;step into a standard directory
;otherwise step into a subfile subdirectory
	ex.s hl,de
	lea de,iy
	ld e,0
	res 0,d
	add hl,de
	push hl
	pop iy
	jq .main_search_loop
.step_into_regular_dir:
	push de
	call fs_GetSectorAddress
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
	ld iy,(ix-20) ;restore iy
	ld sp,ix
	pop ix
	ret

.return_file_entry_point:
	ld bc,(ix-26)
	inc bc
	ld (ix-26),bc
	ld hl,(iy+$C)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	call .search_loop
	jq z,.fail
	jq .return


;searches for a file name in a directory listing
.search_next:
	ld hl,(ix-6)
	push hl
	call sys_Free
	pop bc
	lea iy,iy+16
.search_loop:
	ld a,(iy)
	or a,a
	ret z ;reached end of directory
	inc a
	ret z ;reached end of directory
	cp a,fsentry_deleted+1
	jq z,.search_next
	cp a,fsentry_longfilename+1
	jq z,.search_next
	push iy
	call fs_CopyFileName ;get file name string from file entry
	ld (ix-6),hl
	push hl
	call ti._strlen ;get length of file name string from file entry
	ld bc,(ix-23) ;compare lengths
	or a,a
	sbc hl,bc
	add hl,bc
	pop bc,iy
	jq nz,.search_next
	push iy,hl,bc
	ld bc,(ix-26)
	push bc
	call ti._strncmp ;compare with the target directory if the lengths are the same
	pop bc,bc,bc,iy
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,.search_next ;check next file entry
	ld hl,(ix-6)
	push hl
	call sys_Free
	pop bc
	xor a,a
	inc a
	ret

