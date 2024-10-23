;@DOES Open a file given a file name and mode.
;@INPUT void** fsd_Open(const char* path, const char* mode);
;@OUTPUT file descriptor, or 0 if failed.
fsd_Open:
	ld hl,-6
	call ti._frameset
	ld (ix-3),iy

; get the file descriptor if the file exists
	ld hl,(ix+6)
	push hl
	call fs_OpenFile
	pop bc
	ld (ix-6),hl

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
	call nz,.create
	ld b,fsd_bNeedsFlush or fsd_bWrite
	jr .append_table

.open_read:
	ld hl,(ix-6)
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	dec hl
	jq nz,.fail
	jr .append_table

.open_write:
	ld hl,(ix-6)
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	dec hl
	call nz,.create
	ld b,fsd_bNeedsFlush or fsd_bWrite or fsd_bOverwrite

.append_table:
	xor a,a
	or a,c
	jr z,.not_both_rw
	ld a,fsd_mWrite or fsd_mRead or fsd_mNeedsFlush
.not_both_rw:
	or a,b
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
	call fs_GetFDPtr
	ld (iy+3),hl ; file data pointer
	call fs_GetFDLen
	ld (iy+6),hl ; file data length
	pop bc
	bit fsd_bWrite,(iy-1)
	jr z,.done ; don't move data to ram if writing not needed
	call fs_ChkFreeRam
	ld de,(iy+6)
	or a,a
	sbc hl,de
	jr c,.fail_ensure_closed
	ld hl,(iy+6)
	add hl,bc
	or a,a
	sbc hl,bc
	jr nz,.alloc_over_zero_size
	inc hl
	ld (iy+6),hl
.alloc_over_zero_size:
	call fs_AllocRam.entryhl
	ex hl,de
	ld hl,(iy+3)
	ld bc,(iy+6)
	ldir
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
	ld hl,(ix-6)
	call fsd_CheckOpenFD.entryhl
	add hl,de
	or a,a
	sbc hl,de
	ret z
	dec hl
	ld (hl),0
	ret

.create:
	ld hl,(ix+6)
	ld bc,0
	push bc,bc,hl
	call fs_CreateFile
	pop bc,bc,bc
	ld (ix-6),hl
	ret
