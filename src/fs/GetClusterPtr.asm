
;@DOES read a given cluster of a file descriptor
;@INPUT void *fs_GetClusterPtr(void *fd, int cluster);
;@OUTPUT hl = pointer to sector. hl = -1 if failed.
;@NOTE this does not guarantee a contiguous memory space, as files can be fragmented in FAT filesystems.
fs_GetClusterPtr:
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
	add hl,de  ;check if fd is null
	or a,a
	sbc hl,de
	jr z,.fail
	inc hl     ;check if fd is -1
	add hl,de
	or a,a
	sbc hl,de
	jr z,.fail
	dec hl
	push de
	ld bc,$14
	add hl,bc
	ld a,(hl)  ;upper byte of file starting cluster
	ld c,$1A - $14
	add hl,bc
	ld bc,(hl) ;low two bytes of file starting cluster
	ld (ScrapMem),bc
	ld (ScrapMem+2),a
	push hl
	ld hl,(ScrapMem)
	add hl,hl  ;multiply by 4
	add hl,hl
	ex (sp),hl
	call fs_DriveLetterFromPtr
	ld (ScrapByte),a
	call nc,fs_ClusterMap
	ld (ScrapMem),hl
	pop bc
	pop de
	jq c,.fail
	add hl,bc
.loop:
	ex hl,de
	add hl,de
	or a,a
	sbc hl,de
	ex hl,de
	jr z,.exit
	push de
	ld a,(hl)
	cp a,$FF
	jr nz,.next
	inc hl
	ld hl,(hl)
	ld de,$0FFFFF
	or a,a
	sbc hl,de
	add hl,de
.next:
	pop de
	jr z,.fail
	dec de
	ld hl,(hl)
	add hl,hl
	add hl,hl
	ld bc,(ScrapMem)
	add hl,bc
	jr .loop
.fail:
	scf
	sbc hl,hl
	ret
.exit:
	ld bc,(ScrapMem)
	or a,a
	sbc hl,bc
	ld b,8     ;multiply by cluster size / cluster map entry size
.mult_loop:
	add hl,hl
	djnz .mult_loop
	push hl
	ld a,(ScrapByte)
	call fs_DataSection
	pop bc
	jq c,.fail ;hope this doesn't happen
	add hl,bc
	xor a,a
	ret
