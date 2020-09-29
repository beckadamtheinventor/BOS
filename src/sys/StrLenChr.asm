;@DOES return offset in string that a character appears, if character is not found returns string length
;@INPUT int sys_StrLenChr(char *str, char c);
sys_StrLenChr:
	pop de,hl,bc
	push bc,hl,de
	ld a,c
	push af
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	pop af
	push bc
	push hl
	cpir
	jr nz,.not_found
	pop bc,de
	or a,a
	sbc hl,bc
	ret
.not_found:
	pop bc,hl
	ret
