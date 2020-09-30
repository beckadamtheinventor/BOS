;@DOES read data from a file into RAM
;@INPUT int fs_Read(void *dest, int len, uint8_t count, void *fd);
;@OUTPUT number of bytes read
;@DESTROYS All, OP6
fs_Read:
	push iy
	ld hl,-3
	call ti._frameset
	ld hl,(ix+9)
	ld (ix-3),hl
	or a,a
	sbc hl,hl
	ld de,(ix+12)
	ld b,(ix+15)
.get_len_loop:
	add hl,de
	djnz .get_len_loop
	push hl
	push iy
	ld iy,(ix+18)
	ld de,0
	ld bc,1024
	jr .entry
.copy_loop:
	push hl,iy,de
	call fs_GetClusterPtr
	jq c,.fail
	ld de,(ix-3)
	ld bc,1024
	ldir
	ld (ix-3),de
	pop de,iy,hl
	inc de
	ld bc,1024
	or a,a
	sbc hl,bc
.entry:
	sbc hl,bc
	add hl,bc
	jr nc,.copy_loop
	push hl,iy,de
	call fs_GetClusterPtr
	pop de,bc,bc
	ld de,(ix-3)
	ldir
	jr .exit
.fail:
	xor a,a
	sbc hl,hl
.exit:
	ld sp,ix
	pop ix
	pop iy
	ret
