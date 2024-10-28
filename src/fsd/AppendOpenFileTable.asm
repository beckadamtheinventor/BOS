;@DOES Append the open files table given a file descriptor and mode byte.
;@INPUT void** fsd_AppendOpenFileTable(void* fd, char mode);
;@OUTPUT pointer-to-pointer to file descriptor, or 0 if table is full.
;@NOTE returns pointer-to-pointer to existing descriptor if it exists.
fsd_AppendOpenFileTable:
	call ti._frameset0
	ld c,(ix+9)
	ld hl,(ix+6)
	ld ix,open_file_table-1-fsd_StructureLen
	ld b,open_file_table.max_open
.loop:
	lea ix,ix+fsd_StructureLen
	ld a,(ix+fsd_OpenFlags+1)
	or a,a
	jr z,.found_empty
	ld de,(ix+fsd_FileDesc+1)
	sbc hl,de
	add hl,de
	jr z,.found_existing
	djnz .loop
	jr .fail
.found_empty:
	ld (ix+fsd_OpenFlags+1),c
	ld (ix+fsd_FileDesc+1),hl
	or a,a
	sbc hl,hl
	ld (ix+fsd_DataPtr+1),hl
	ld (ix+fsd_DataLen+1),hl
	ld (ix+fsd_DataOffset+1),hl
.found_existing:
	lea hl,ix+fsd_FileDesc+1
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
	pop ix
	ret
