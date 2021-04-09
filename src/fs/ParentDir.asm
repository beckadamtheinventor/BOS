
;@DOES return a string representing the parent directory of a given path.
;@INPUT char *fs_ParentDir(const char *path);
;@OUTPUT HL = string representing path to parent directory. Returns -1 and Cf on fail.
fs_ParentDir:
	pop bc,hl
	push hl,bc
	push hl
	call fs_AbsPath
	inc hl
	ld a,(hl)
	dec hl
	or a,a
	jq z,.return
	ex (sp),hl
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	ld a,'/'
	add hl,bc
	dec hl
	cp a,(hl)
	jq nz,.doesnt_end_with_slash
	dec hl
.doesnt_end_with_slash:
	cpdr ;find last '/' in path string
	inc hl
	pop de
	sbc hl,de
	jq c,.return_root_dir
	ld a,l
	or a,h
	jq z,.return_root_dir
	inc hl
	push de,hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	ret c
	push de
	ldir ;copy the path up until last '/'
	xor a,a
	ld (de),a ;terminate the string
.return:
	pop hl
	ret
.return_root_dir:
	ld hl,2
	push hl
	call sys_Malloc
	pop bc
	ret c
	ld (hl),'/'
	inc hl
	ld (hl),b
	dec hl
	ret

