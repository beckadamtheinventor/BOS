;@DOES Return length of file data given a file descriptor
;@INPUT int fs_GetFDLenRaw(void *fd);
;@OUTPUT length of file data. Will be 0 if data has not been initizlized yet.
;@DESTROYS HL,DE
fs_GetFDLenRaw:
	pop de,hl
	push hl,de
.entry:
	ld de,fsentry_filesector
	add hl,de
	ld a,(hl)
	inc hl
	and a,(hl)
	inc hl
	inc a
	jr z,.nodata
	ld de,(hl)
	ex.s hl,de
	ld a,l
	or a,h
	ret nz
; file size of 0 implies size of 65536
	dec l   ; hl = 0x0000FF
	ld h,l  ; hl = 0x00FFFF
	inc hl  ; hl = 0x010000
	ret
.nodata:
	or a,a
	sbc hl,hl
	ret
