;@DOES Check if a file is open
;@INPUT bool fsd_IsOpen(void** fd);
;@OUTPUT true if open.
fsd_IsOpen:
	pop bc,hl
	push hl,bc
.entryhl:
assert fsd_OpenFlags = -1
	dec hl
	ld a,(hl)
	inc hl
	or a,a
	ret

