;@DOES Read some data from an open file descriptor, advancing the file offset
;@INPUT int fsd_Read(void* buffer, size_t len, size_t count, void** fd);
;@OUTPUT count if success.
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
	bit fsd_bRead, (iy+fsd_OpenFlags) ; check if readable
	jr z,.fail
	bit fsd_bIsDevice, (iy+fsd_OpenFlags) ; check if device
	jr z,.device
	ld bc,(iy+fsd_DataOffset) ; offset
	add hl,bc ; offset + len
	ld bc,(iy+fsd_DataLen) ; file_length
	or a,a
	sbc hl,bc
	add hl,bc
	jr c,.within_size ; jump if offset + len < file_length
	push bc
	pop hl
	ld bc,(iy+fsd_DataOffset) ; offset
	add hl,bc
	ld (ix-6),hl ; override length of read to match file bounds
.within_size:
	ld hl,(iy+fsd_DataPtr) ; data pointer
	ld bc,(iy+fsd_DataOffset) ; data offset
	add hl,bc
	ld de,(ix+6) ; data to read
	ld bc,(ix-6) ; len*count of data to read
	push bc
	ldir ; copy the data
	pop de
; advance the file offset
	ld hl,(iy+fsd_DataOffset)
	add hl,de
	ld (iy+fsd_DataOffset),hl
	ld hl,(ix+12)
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
.done:
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret

.device:
	ld hl,(iy+fsd_DataOffset)
	push hl
	ld hl,(ix-6) ; len * count
	push hl
	ld hl,(ix+6) ; buffer
	push hl
	ld hl,(iy+fsd_DataPtr)
	push hl
	call drv_Read
	jr .done
