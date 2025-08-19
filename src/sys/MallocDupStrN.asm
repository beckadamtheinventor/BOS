;@DOES Malloc a copy of a string up to N characters.
;@INPUT char *sys_MallocDupStrN(const char *str, size_t len);
;@OUTPUT Malloc'd copy and Cf unset or zero and Cf set if failed.
sys_MallocDupStrN:
	pop de,hl,bc
	push bc,hl,de
.entryhlbc:
	ld de,0
	push bc,de,hl
	call ti._memchr
	pop de,bc,bc
	push de
	jq sys_MallocDupStr._malloc_hl_plus_1
