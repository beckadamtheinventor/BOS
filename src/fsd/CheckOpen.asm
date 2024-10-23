;@DOES Check if a file is open, returning a pointer-to-pointer if it is.
;@INPUT void** fsd_CheckOpen(const char* path);
;@OUTPUT pointer-to-pointer to file descriptor, 0 otherwise.
fsd_CheckOpen:
	pop bc,hl
	push hl,bc
.entryhl:
	push hl
	call fs_OpenFile
	pop bc
	inc hl ; adjust for error case -1 -> 0
	ret c
	dec hl
	jr fsd_CheckOpenFD.entryhl

