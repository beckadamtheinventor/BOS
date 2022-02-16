
;@DOES allocate a small amount of flash memory.
;@INPUT void *fs_AllocSmall(int len);
;@OUTPUT returns a pointer to allocated memory, or -1 and Cf set if failed.
;@NOTE size to be allocated must be less than or equal to 254 bytes, and greater than 0.
fs_AllocSmall:
	ld hl,-10
	call ti._frameset
	ld hl,(ix+3)
	ld bc,254
	scf
	sbc hl,bc
	jq nc,.fail
	ld a,(ix+3)
	or a,a
	jq z,.fail

	sbc hl,hl
	ld (ix-3),hl

	push iy
	ld iy,fs_root_dir_address
.findeodloop:
	ld a,(iy)
	inc a
	jr z,.foundeod
	cp a,fsentry_unlisted+1
	jr nz,.checknextentry
	ld a,(iy+1)
	inc a
	jr nz,.checknextentry
	ld (ix-3),iy
.checknextentry:
	lea iy,iy + fs_file_desc_size
	jr .findeodloop
.foundeod:
	pop iy
	ld hl,(ix-3) ; points to last found unlisted file entry in the root directory with a file name starting with 0xFF
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,.allocmoresectors ; allocate a new block file if none found
	call fs_GetFDPtr.entry
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.allocmoresectors
	dec hl
.findfreebytesloop:
	ld a,(hl)
	inc a
	jr z,.allocatebytes
	ld c,(hl)
	inc hl
	add hl,bc
	jr .findfreebytesloop
.allocatebytes:
	ld c,(ix+6)
	add hl,bc ; search pointer + arg
	inc hl ; +1 to account for length byte
	ex hl,de ; de = potential write location, hl = end of current block
	scf
	sbc hl,de ; end of current block - (potential write location + arg + 1)
	jr c,.allocmoresectors ; keep looking if arg bytes can't fit here

	call sys_FlashUnlock
	ld a,(ix+6)
	ld sp,ix
	pop ix

	call sys_WriteFlashA
	ex hl,de
	jq sys_FlashLock
.allocmoresectors:
	ld de,fscluster_smallallocblocksize
	lea hl,ix-7
	ld c,fd_hidden
	push de,bc,hl
	ld (hl),fsentry_unlisted
	inc hl
	ex hl,de
	ld hl,(ix-3)
	ld bc,$0101
	add hl,bc
	ex hl,de
	ld (hl),de
	inc hl
	inc hl
	inc hl
	ld (hl),0
	call fs_CreateFile
	ex hl,de
	pop hl,bc,bc
	add hl,de
	ex hl,de
	jr nc,.allocatebytes ; shouldn't fail now, we just allocated plenty of space.
; fail if sector allocation failed
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
	

