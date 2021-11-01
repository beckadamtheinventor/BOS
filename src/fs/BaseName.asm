;@DOES return the last path word of a path
;@INPUT char *fs_BaseName(const char *path);
;@OUTPUT last path word, or same as input if it is the only path word.
fs_BaseName:
	pop bc,hl
	push hl,bc,hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	ld a,'/'
	cpdr
	inc hl ; increment to first character of the string
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
