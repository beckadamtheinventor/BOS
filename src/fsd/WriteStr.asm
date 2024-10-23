;@DOES Write a string to an open file descriptor, advancing the file offset.
;@INPUT int fsd_WriteStr(const char* str, void** fd);
;@OUTPUT number of bytes written.
fsd_WriteStr:
	pop bc,de,hl
	push hl,de,bc
	push de,hl ; push fd, str
	call ti._strlen ; strlen(str)
	pop bc ; pop str
	push hl ; strlen(str) -> count
	ld hl,1
	push hl ; 1 -> len
	push bc ; str -> buffer
	call fsd_Write
	pop bc,bc,bc,bc
	ret
