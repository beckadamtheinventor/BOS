;@DOES Check if a file descriptor is open, returning a pointer-to-pointer if it is.
;@INPUT void** fsd_CheckOpenFD(void* fd);
;@OUTPUT pointer-to-pointer to file descriptor, 0 otherwise.
fsd_CheckOpenFD:
	pop bc,hl
	push hl,bc
.entryhl:
	push iy
	ld iy,open_file_table-13
	ld b,open_file_table.max_open
.loop:
	lea iy,iy+13
	ld a,(iy+0)
	or a,a
	jr z,.next
	ld de,(iy+1)
	sbc hl,de
	add hl,de
	jr z,.found
.next:
	djnz .loop
	or a,a
	sbc hl,hl
	db $01 ; ld bc,... dummify lea
.found:
	lea hl,iy+1
	pop iy
	ret
