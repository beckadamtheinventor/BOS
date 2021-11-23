;@DOES Free space allocated to a file
;@INPUT int fs_Free(void *fd);
;@OUTPUT number of sectors freed.
fs_Free:
	pop bc,hl
	push hl,bc
	ld bc,fsentry_fileattr
	add hl,bc
	bit fd_subfile,(hl)
	jq nz,.zero
	inc hl
	ld de,(hl)
	bit 7,d
	jq nz,.zero ; dont free it if its a ram or device file
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld a,c
	or a,b
	jq z,.zero ; dont free it if it hasnt been allocated
.entrydebc:
	ex.s hl,de
	ld de,fs_cluster_map
	add hl,de
	ex hl,de
	ld a,b
	and a,1
	or a,c
	jq z,.exact
	inc b
	inc b
	or a,a
.exact:
	ld a,b
	rra
	ld c,a
	ld hl,$FF0000
	ld b,l ; bc = file_len/512 + (file_len%512 > 0)
	push bc
	call sys_FlashUnlock
	call sys_WriteFlash
	call sys_FlashLock
	pop hl ;return number of sectors freed
	or a,a
	ret
.zero:
	or a,a
	sbc hl,hl
	ret
