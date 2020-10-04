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
	jq nc,.fail ;fail if offset>=len
	ld bc,1024    ;cluster size
	call ti._idivu
	ld (ix-6),hl  ;offset>>10
	ld hl,(ix+21)
	ld a,h
	and a,3
	ld h,a
	ex.s hl,de ;offset&0x3FF
	ld hl,1024
	or a,a
	sbc hl,de
	push hl
	ld hl,(ix+18)
	ld de,(ix-6)
	push de,hl
	call fs_GetClusterPtr
	jq c,.fail
	pop bc,bc
	add hl,bc ;add offset&0x3FF
	pop bc
	ld de,(ix-3)
	push bc
	ldir
	ld (ix-3),de
	or a,a
	sbc hl,hl
	ld de,(ix+12) ;int len
	ld b,(ix+15)  ;uint8_t count
.get_len_loop:
	add hl,de
	djnz .get_len_loop
	ld (ix-9),hl
	pop de
	or a,a
	sbc hl,de
	jq z,.return
	ld bc,1024
	call ti._idivu
	inc hl
	ld (ix-6),hl
	ld hl,(ix+18)
	ld de,0
	ld bc,1024
	jq .entry
.copy_loop:
	push de,hl
	call fs_GetClusterPtr
	jq c,.fail
	ld de,(ix-3) ;dest
	ld bc,1024
	ldir
	ld (ix-3),de ;no more need to offset
	pop hl,de
.entry:
	push hl
	ld hl,(ix-6)
	or a,a
	sbc hl,de
	inc de
	pop hl
	jq nc,.copy_loop
.return:
	ld hl,(ix-9)
	db $01 ;dummify next 3 bytes
.fail:
	xor a,a   ;1 byte
	sbc hl,hl ;2 bytes
.exit:
	ld sp,ix
	pop ix
	pop iy
	ret
