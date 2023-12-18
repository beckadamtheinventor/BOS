;@DOES Return file attribute byte for a given descriptor
;@INPUT uint8_t fs_GetFDAttr(void *fd);
;@OUTPUT attribute byte in A
fs_GetFDAttr:
	pop bc,hl
	push hl,bc
.entry:
	ld bc,fsentry_fileattr
	add hl,bc
	ld a,(hl)
	ret
