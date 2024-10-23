;@DOES Close an open file descriptor, writing changes if needed.
;@INPUT void fsd_Close(void* fd);
fsd_Close:
	pop bc,hl
	push hl,bc
.entryhl:
	call fsd_CheckOpenFD.entryhl
	add hl,de
	or a,a
	sbc hl,de
	ret z
	ld de,(hl) ; file descriptor
	dec hl
	ld a,(hl)
	ld (hl),0 ; close the entry in the table
	bit fsd_bNeedsFlush,a
	ret z ; dont flush if not needed
.entryflush:
	push hl
	ex (sp),iy ; iy = pointer-to-pointer
	ld hl,(iy) ; file descriptor
	push hl
	ld hl,(iy+6) ; data length
	push hl
	ld hl,(iy+3) ; data pointer
	push hl
	call fs_WriteFile ; overwrite file with new data
	pop bc,bc,bc
	pop iy
	ret
