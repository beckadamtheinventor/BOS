;@DOES Free space allocated to a file
;@INPUT int fs_Free(void *fd);
;@OUTPUT number of sectors freed.
fs_Free:
	pop bc,hl
	push hl,bc
.entryhl:
	ld bc,fsentry_fileattr
	add hl,bc
	bit fd_subfile,(hl)
	jq nz,.zero
	inc hl
	ld de,(hl)
	; bit 7,d
	; jq nz,.zero ; dont free it if its a ram or device file
	ld a,d
	and a,e
	inc a
	jr z,.zero
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld a,c
	or a,b
	jr z,.zero ; dont free it if it hasnt been allocated
.entrydebc: ; free bc bytes starting at sector de
	ex.s hl,de
	ld de,fs_cluster_map
	add hl,de
	push hl
	push bc
	pop hl
	call fs_CeilDivBySector
	ex (sp),hl
	pop bc
	ex hl,de
	ld hl,$FF0000 ; pointer to null
	push bc ; bc = ceil(file_len/sector size)
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
