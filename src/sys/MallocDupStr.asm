;@DOES Malloc a copy of a string.
;@INPUT char *sys_MallocDupStr(const char *str);
;@OUTPUT Malloc'd copy and Cf unset or zero and Cf set if failed.
sys_MallocDupStr:
	pop bc,hl
	push hl,bc
.entryhl:
	push hl
	call ti._strlen
.__malloc_string:
	inc hl
	push hl
	call sys_Malloc.entryhl; malloc the new string, accounting for the null terminator.
	pop bc ; string length
	pop de ; pointer to original string
	ret c ; return what malloc returned if we failed to malloc
	push hl
	ex hl,de
	ldir ; copy the original string into the new malloc'd string
	pop hl ; return the new malloc'd string
	ret
