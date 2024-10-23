;@DOES Write some data to an open file descriptor, advancing the file offset.
;@INPUT int fsd_Write(void* buffer, size_t len, size_t count, void** fd);
;@OUTPUT number of bytes written.
fsd_Write:
	ld hl,-6
	call ti._frameset
	ld (ix-3),iy
	ld hl,(ix+9) ; len
	ld bc,(ix+12) ; count
	call ti._imulu
	ld (ix-6),hl ; len*count
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.done ; no data to write
	ld iy,(ix+15)
	bit fsd_bWrite, (iy-1) ; check if writeable
	jr z,.fail
	ld bc,(iy+9) ; offset
	add hl,bc ; offset + len
	ld bc,(iy+6) ; file_length
	or a,a
	sbc hl,bc
	add hl,bc
	jr c,.no_resize ; jump if offset + len < file_length
	push iy,hl
	call fsd_Resize
	pop bc,iy
.no_resize:
	ld hl,(iy+3) ; data pointer
	ld bc,(iy+9) ; data offset
	add hl,bc
	ex hl,de
	ld hl,(ix+6) ; data to write
	ld bc,(ix-6) ; len*count of data to write
	push bc
	ldir ; copy the data
	pop de
; advance the file offset
	ld hl,(iy+9)
	add hl,de
	ld (iy+9),hl
	ex hl,de
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
.done:
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret

