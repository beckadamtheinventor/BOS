;@DOES Get the length of a path string
;@INPUT int fs_PathLen(const char *path);
;@OUTPUT hl = length of path, de = pointer to end of path, a = end of path character
fs_PathLen:
	pop bc,de
	push de,bc
.entryde:
	or a,a
	sbc hl,hl
.loop:
	ld a,(de)
	inc a
	ret z
	dec a
	ret z
	cp a,' '
	ret z
	cp a,':'
	ret z
	cp a,$A
	ret z
	cp a,$9
	ret z
	cp a,$5C ;backslash
	inc hl
	inc de
	jr nz,.loop
	inc hl
	inc de
	jr .loop
