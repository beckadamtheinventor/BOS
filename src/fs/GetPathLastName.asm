;@DOES get last file name from a path. Equivalent to python path.split("/")[-1]
;@INPUT char *fs_GetPathLastName(char *path);
;@OUTPUT pointer to file name
;@NOTE this will return the last entry in the path, regardless of whether the path exists or if it points to a program entrypoint.
fs_GetPathLastName:
	pop bc
	pop hl
	push hl
	push bc
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	add hl,bc
	ld a,'/'
	cpdr
	inc hl
	ret
