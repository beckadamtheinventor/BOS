;@DOES Check if a file descriptor is open, returning a pointer-to-pointer if it is.
;@INPUT void** fsd_CheckOpenFD(void* fd);
;@OUTPUT pointer-to-pointer to file descriptor, 0 otherwise.
fsd_CheckOpenFD:
	pop bc,hl
	push hl,bc
.entryhl:
	push iy
	ld iy,open_file_table-1-fsd_StructureLen
	ld b,open_file_table.max_open
.loop:
	lea iy,iy+fsd_StructureLen
	ld a,(iy+fsd_OpenFlags+1)
	or a,a
	jr z,.next
	ld de,(iy+fsd_FileDesc+1)
	sbc hl,de
	add hl,de
	jr z,.found
.next:
	djnz .loop
	or a,a
	sbc hl,hl
	db $01 ; ld bc,... dummify lea
.found:
	lea hl,iy+fsd_FileDesc+1
	pop iy
	ret
