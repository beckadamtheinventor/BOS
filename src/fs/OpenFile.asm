
;@DOES Opens a file from a path and returns file descriptor.
;@INPUT void *fs_OpenFile(char *path);
;@OUTPUT hl = file descriptor. hl is -1 if file does not exist.
;@DESTROYS All, OP5, OP6
fs_OpenFile:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	inc hl
	ld a,(hl)
	cp a,':'
	jr z,.abspath
	ld hl,current_working_dir
	ld a,(hl)
	or a,a
	jq nz,.cwdnonzero
.fail_popbc:
	pop bc
	scf
	sbc hl,hl
	ret
.cwdnonzero:
	pop hl
	push hl
	push hl
	call ti._strlen
	pop bc
	ld (fsOP6+3),hl
	push hl
	ld hl,current_working_dir
	push hl
	call ti._strlen
	pop bc
	pop bc
	ld (fsOP6),hl
	add hl,bc
	inc hl
	push hl
	call sys_Malloc
	pop bc
	jq c,.fail_popbc
	ld (fsOP6+6),hl
	ex hl,de
	ld hl,current_working_dir
	ld bc,(fsOP6)
	ldir
	pop hl
	ld bc,(fsOP6+3)
	ldir
	xor a,a
	ld (de),a
	ld hl,(fsOP6+6)
	jr .next
.abspath:
	pop hl
.next:
	ld a,(hl)
	inc hl
	inc hl
	inc hl
	ld (fsOP6),hl
	push hl,af
	call strupper
	pop af
	call fs_RootDir
	pop de
	jq c,.fail
	ld a,(de)
	or a,a
	ret z ;return root directory
	cp a,' '
	ret z ;return root directory
	ld (fsOP5),hl  ; save drive data section
	push ix
	push hl
	pop ix
	db $01 ;ld bc,...
.search_next:
	lea ix,ix+32
.search_loop:
	ld a,(ix)
	or a,a
	jq z,.fail_popix ;reached end of directory
	ld bc,fsOP6+3
	push ix,bc
	call fs_CopyFileName ;get file name string from file entry
	pop bc,ix
	push bc
	call ti._strlen ;get length of file name string from file entry
	ex (sp),hl
	push hl
	ld bc,(fsOP6)
	push bc
	call ti._memcmp ;compare with the target directory
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jr nz,.search_next ;check next file entry

.into_dir:
	ld hl,(fsOP6)
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,'/'
	cpir
	jr nz,.return
	bit fsbit_subdirectory,(ix + fsentry_fileattr) ;check if we're entering a directory
	jr z,.fail_popix
.next_path_entry:
	ld a,'/'
	dec hl
.next_path_skip_slash_loop:
	cpi
	jr z,.next_path_skip_slash_loop
	ld (fsOP6),hl ;advance path entry
	ld hl,(ix+$12) ;load byte at ix+$14 into hl upper byte
	ld l,(ix+$1A) ;load low two bytes
	ld h,(ix+$1B)
	ld b,10           ; multiply by 1024 to get directory entries cluster
.cluster_mult_loop2:
	add hl,hl
	djnz .cluster_mult_loop2
	ld bc,(fsOP5)
	add hl,bc        ; add address of data section
	push hl
	pop ix
	jr .search_loop
.fail_popix:
	pop ix
.fail:
	scf
	sbc hl,hl
	ret
.return:
	lea hl,ix
	pop ix
	xor a,a
	ret
