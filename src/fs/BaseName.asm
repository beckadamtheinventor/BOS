;@DOES return the last path word of a path
;@INPUT char *fs_BaseName(const char *path);
;@OUTPUT copy of last path word, or same as input if it is the only path word, or pointer to '/' if that is the last character of the path.
fs_BaseName:
	pop bc,hl
	push hl,bc
.entryhl:
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	ld a,'/'
	cp a,(hl)
	ret z
	cpdr
	ret po ; return if '/' not found in path string
	inc hl
	push hl ; otherwise return a copy of the string at hl (last path word)
	call ti._strlen
	push hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	inc bc
	push de
	ldir
	pop hl
	ret
