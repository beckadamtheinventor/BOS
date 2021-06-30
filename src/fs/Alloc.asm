;@DOES allocate space for a file
;@INPUT int fs_Alloc(int len);
;@OUTPUT hl = first sector allocated
fs_Alloc:
	ld hl,-10
	call ti._frameset
	ld hl,(ix+6)
	call fs_CeilDivBySector

	ld a,l
	or a,a
	jq nz,.notonesector
	inc a
.notonesector:
	ld (ix-4),a

	ld hl,fs_cluster_map_file
	push hl
	call fs_OpenFile
	pop bc
	call c,fs_SanityCheck

	ld bc,$C
	add hl,bc
	ld hl,(hl)
	push hl
	call fs_GetSectorAddress
	pop bc
	ld (ix-10),hl
	ld (ix-3),hl
	ld bc,8192
	add hl,bc
	ld (ix-7),hl
	ld hl,(ix-3)
	dec hl
.search_loop_entry:
	ld a,$FF
	ld de,(ix-7)
.search_loop:
	or a,a
	sbc hl,de
	jq nc,.garbage_collect ;we've hit the end of the cluster map, and we need to do a garbage collect
	adc hl,de
	cp a,(hl)
	jq nz,.search_loop

;found an empty cluster
	ld (ix-3),hl
	ld b,(ix-4)
	dec b
	jq z,.success
	ld a,$FF
.len_loop:
	or a,a
	sbc hl,de
	jq nc,.garbage_collect ;we've hit the end of the cluster map, and we need to do a garbage collect
	adc hl,de
	cp a,(hl)
	jq nz,.search_loop_entry ;area not long enough
	djnz .len_loop

;if we're here, we succeeded :D
.success:
	call sys_FlashUnlock

	ld de,(ix-3)
	ld b,(ix-4)
	ld c,$FE
.reserve_loop:
	push bc,de
	ld a,c
	call sys_WriteFlashA
	pop de,bc
	inc de
	djnz .reserve_loop

	call sys_FlashLock

	ld hl,(ix-3)
	ld de,(ix-10)
	or a,a
	sbc hl,de ;return first allocated cluster

	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.garbage_collect:
	call fs_GarbageCollect
	jq .fail ;still make it a fail case for now, until garbage collect actually moves things around


