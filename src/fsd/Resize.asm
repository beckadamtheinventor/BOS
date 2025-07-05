;@DOES Resize a file in ram.
;@INPUT int fsd_Resize(size_t len, void** fd);
;@OUTPUT new file size, 0 if failed.
;@NOTE resets file offset if decreasing size.
fsd_Resize:
	ld hl,-3
	call ti._frameset
	ld (ix-3),iy
	ld iy,(ix+9)
	bit fsd_bWrite, (iy+fsd_OpenFlags) ; check if writeable
	jr z,.fail
	bit fsd_bIsDevice, (iy+fsd_OpenFlags) ; check if device
	jr nz,.fail ; can't resize device
	ld hl,(iy+fsd_DataLen) ; data current length
	ld de,(ix+6) ; new length
	or a,a
	sbc hl,de
	jr z,.done ; new == current
	jr c,.increase_size ; new > current
	ex hl,de ; de = current - new
	ld hl,(iy+fsd_DataPtr) ; data pointer
	ld bc,(ix+6) ; data new length
	add hl,bc
	push iy ; save iy
	call _DelMem ; remove current_len - new_len bytes from the file at offset new_len
	pop iy
	or a,a
	sbc hl,hl
	ld (iy+fsd_DataOffset),hl ; reset offset
	jr .done
.increase_size:
	ld hl,(iy+fsd_DataPtr) ; data pointer
	ld de,(iy+fsd_DataLen) ; data current length
	add hl,de
	push hl
	ld hl,(ix+6) ; new length
	or a,a
	sbc hl,de ; new - current
	pop de
	push iy
	call _InsertMem ; insert new_len - current_len bytes at the current end of file
	pop iy
	ld hl,(ix+6)
	ld (iy+fsd_DataLen),hl
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
.done:
	ld hl,(iy+fsd_DataLen)
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret
