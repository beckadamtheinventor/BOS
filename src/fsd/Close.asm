;@DOES Close an open file descriptor, writing changes if needed.
;@INPUT void fsd_Close(void** fd);
fsd_Close:
	pop bc,hl
	push hl,bc
.entryhl:
	; call fsd_CheckOpenFD.entryhl
	; add hl,de
	; or a,a
	; sbc hl,de
	; ret z
assert fsd_OpenFlags = -1
	dec hl
	ld a,(hl)
	ld (hl),0 ; close the entry in the table
	inc hl
	bit fsd_bIsDevice,a
	jr nz,.close_device
	bit fsd_bNeedsFlush,a
	ret z ; dont flush if not needed
.entryflushhl:
	push hl
	ex (sp),iy ; iy = pointer-to-pointer
	ld hl,(iy+fsd_FileDesc) ; file descriptor
	push hl
	ld hl,(iy+fsd_DataLen) ; data length
	push hl
	ld hl,(iy+fsd_DataPtr) ; data pointer
	push hl
	call fs_WriteFile ; overwrite file with new data
	pop bc,bc,bc
	push hl
	ld hl,(iy+fsd_DataPtr)
	ld de,(iy+fsd_DataLen)
	call _DelMem ; unload from ram
	call fs_GetFDPtr
	ld (iy+fsd_DataPtr),hl ; overwrite data pointer
	pop bc
	ex (sp),iy
	pop hl
	ret

.close_device:
	ex hl,de
assert fsd_DataPtr = 3
	inc hl
	inc hl
	inc hl
	ld de,(hl) ; data pointer / device structure
	push de
	call drv_DeinitDevice
	pop de
	ret
