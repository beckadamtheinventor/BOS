;@DOES Append the open files table given a file descriptor and mode byte.
;@INPUT void** fsd_AppendOpenFileTable(void* fd, char mode);
;@OUTPUT pointer-to-pointer to file descriptor, or 0 if table is full.
fsd_AppendOpenFileTable:
	call ti._frameset0
	ld c,(ix+9)
	ld hl,(ix+6)
	ld ix,open_file_table-13
	ld b,open_file_table.max_open
.loop:
	lea ix,ix+13
	ld a,(ix+0)
	or a,a
	jr z,.found_empty
	ld de,(ix+1)
	sbc hl,de
	add hl,de
	jr z,.found_existing
	djnz .loop
	jr .fail
.found_empty:
	ld (ix+0),c
	ld (ix+1),hl
	or a,a
	sbc hl,hl
	ld (ix+4),hl
	ld (ix+7),hl
	ld (ix+10),hl
.found_existing:
	lea hl,ix+1
.fail:
	or a,a
	sbc hl,hl
	pop ix
	ret
