;@DOES Open a file given a file name and mode.
;@INPUT void** fsd_Open(const char* path, const char* mode);
;@OUTPUT file descriptor, or 0 if failed.
fsd_Open:
	ld hl,-7
	call ti._frameset
	ld (ix-3),iy

; get the file descriptor if the file exists
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	ld (ix-6),hl
	pop bc
	call fs_GetFDAttr.entry
	ld (ix-7),a ; this will be garbage when the file doesn't exist, so overwrite in .create

	ld hl,(ix+9)
	inc hl
	ld a,(hl)
	sub a,'+'
	ld c,a
	dec hl
	ld a,(hl)
	cp a,'r'
	jr z,.open_read
	cp a,'w'
	jr z,.open_write
	cp a,'a'
	jq nz,.fail
.open_append:
	ld hl,(ix-6)
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	dec hl
	call z,.create
	ld b,fsd_mNeedsFlush or fsd_mWrite
	jr .append_table

.open_read:
	ld hl,(ix-6)
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	dec hl
	jq z,.fail
	ld b,fsd_mRead
	jr .append_table

.open_write:
	ld hl,(ix-6)
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	dec hl
	call z,.create
	ld b,fsd_mNeedsFlush or fsd_mWrite or fsd_mOverwrite

.append_table:
	xor a,a
	or a,c
	jr nz,.not_both_rw
	ld b,fsd_mWrite or fsd_mRead or fsd_mNeedsFlush
.not_both_rw:
	ld a,b
	ld c,a
	push bc
	ld hl,(ix-6)
	push hl
	call fsd_AppendOpenFileTable
	add hl,de
	or a,a
	sbc hl,de
	jr z,.fail
	push hl
	pop iy

	ld hl,(ix-6)
	push hl
	call fs_GetFDPtr.entry
	ld (iy+fsd_DataPtr),hl ; file data pointer
	pop hl
	call fs_GetFDLen.entry
	ld (iy+fsd_DataLen),hl ; file data length

	bit fd_device,(ix-7)
	jr z,.dont_set_device_flag
	set fsd_bIsDevice,(iy+fsd_OpenFlags)
	jr .done ; don't move data to ram if reading/writing to a device file
.dont_set_device_flag:
	bit fsd_bWrite,(iy+fsd_OpenFlags)
	jr z,.done ; don't move data to ram if writing not needed
; copy data to ram
	call .unarc
	jr c,.fail_ensure_closed
	lea hl,iy
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
.done:
	ld iy,(ix-3)
	ld sp,ix
	pop ix
	ret

.fail_ensure_closed:
	ld (iy+fsd_OpenFlags),0
	jr .fail

.create:
	ld hl,(ix+6)
	ld bc,0
	ld (ix-7),c ; ensure the file attribute byte matches
	push bc,bc,hl
	call fs_CreateFile
	pop bc,bc,bc
	ld (ix-6),hl
	ret

.unarc:
	call fs_ChkFreeRam
	ld de,(iy+fsd_DataLen)
	or a,a
	sbc hl,de
	ret c
	ld hl,(iy+fsd_DataLen)
	; add hl,bc
	; or a,a
	; sbc hl,bc
	; jr nz,.alloc_over_zero_size
	; inc hl
	; ld (iy+fsd_DataLen),hl
; .alloc_over_zero_size:
	call fs_AllocRam.entryhl
	ex hl,de
	ld hl,(iy+fsd_DataPtr)
	ld bc,(iy+fsd_DataLen)
	ld a,c
	or a,b
	or a,(iy+fsd_DataLen+1)
	push de
	jr z,.no_data_to_copy
	ldir
.no_data_to_copy:
	pop hl
	ld (iy+fsd_DataPtr),hl ; override the data pointer if copying to ram
	ret
