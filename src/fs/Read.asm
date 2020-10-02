;@DOES read data from a file into RAM
;@INPUT int fs_Read(void *dest, int len, uint8_t count, void *fd, int offset);
;@OUTPUT number of bytes read
;@DESTROYS All, OP6
fs_Read:
	push iy
	ld hl,-9
	call ti._frameset
	ld hl,(ix+18) ;void *fd
	ld bc,$1C
	add hl,bc
	ld de,(hl)
	ld hl,(ix+9)  ;void *dest
	ld (ix-3),hl
	ld hl,(ix+21) ;int offset
	or a,a
	sbc hl,de
	add hl,de
	jr nc,.fail ;fail if offset>=len
	ld bc,1024    ;cluster size
	call ti._idivu
	ld (ix-6),hl  ;offset>>10
	ld hl,(ix+21)
	ld l,0
	res 0,h
	res 1,h
	ld (ix-9),hl  ;offset&0x3FF
	or a,a
	sbc hl,hl
	ld de,(ix+12) ;int len
	ld b,(ix+15)  ;uint8_t count
.get_len_loop:
	add hl,de
	djnz .get_len_loop
	push hl
	push iy
	ld iy,(ix+18)
	ld de,(ix-6)
	ld bc,1024
	jr .entry
.copy_loop:
	push hl,de,iy
	call fs_GetClusterPtr
	jq c,.fail
	ld bc,(ix-9) ;offset&0x3FF
	add hl,bc
	ld de,(ix-3) ;dest
	push hl
	ld hl,1024
	or a,a
	sbc hl,bc
	push hl
	pop bc
	pop hl
	ldir
	ld (ix-9),bc ;no more need to offset
	ld (ix-3),de
	pop iy,de,hl
	inc de
	ld bc,1024
	or a,a
.entry:
	sbc hl,bc
	add hl,bc
	jr nc,.copy_loop
	jr z,.exit
	push hl,de,iy
	call fs_GetClusterPtr
	pop bc,de,bc
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
