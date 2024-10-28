;@DOES Close all open files.
;@INPUT void fsd_CloseAll();
fsd_CloseAll:
	push iy
	ld iy,open_file_table-fsd_StructureLen
	ld b,open_file_table.max_open
.loop:
	lea iy,iy+fsd_StructureLen
	ld a,(iy+fsd_OpenFlags)
	or a,a
	jr z,.next
	push bc,iy
	call fsd_Close
	pop iy,bc
.next:
	djnz .loop
	pop iy
	ret
