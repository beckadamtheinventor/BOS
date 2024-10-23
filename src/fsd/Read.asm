;@DOES Read some data from an open file descriptor, advancing the file offset
;@INPUT int fsd_Read(void* buffer, size_t len, size_t count, void** fd);
;@OUTPUT number of bytes read.
fsd_Read:
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
	jr z,.done ; no data to read
	ld iy,(ix+15)
	bit fsd_bRead, (iy-1) ; check if readable
	jr z,.fail
	ld bc,(iy+9) ; offset
	add hl,bc ; offset + len
	ld bc,(iy+6) ; file_length
	or a,a
	sbc hl,bc
	add hl,bc
	jr c,.within_size ; jump if offset + len < file_length
	push bc
	pop hl
	ld bc,(iy+9) ; offset
	add hl,bc
	ld (ix-6),hl ; override length of read to match file bounds
.within_size:
	ld hl,(iy+3) ; data pointer
	ld bc,(iy+9) ; data offset
	add hl,bc
	ld de,(ix+6) ; data to read
	ld bc,(ix-6) ; len*count of data to read
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


