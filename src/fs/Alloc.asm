
;@DOES allocate space in flash for a file
;@INPUT int fs_Alloc(int len);
;@OUTPUT hl = first sector allocated, or -1 and Cf set if failed.
fs_Alloc:
	ld a,fscluster_allocated
;@DOES allocate space in flash with a specified allocation marker
;@INPUT int fs_Alloc(int len); (input allocation marker in A)
;@NOTE You probably shoudln't be calling this in your code unless you know what you're doing.
fs_AllocWithMarker:
	ld hl,-5
	call ti._frameset
	ld (ix-5),a
	ld bc,(ix+6)
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
	ld (ix-4),a

	ld hl,fs_cluster_map + fs_root_dir_lba ; only check clusters following the filesystem root directory
	ld bc,fs_cluster_map.len - fs_root_dir_lba
.search_loop:
	ld a,(hl)
	inc hl
assert fscluster_clean = $FF
	inc a
	jq z,.found
	dec bc
	ld a,c
	or a,b
	jq nz,.search_loop
;we've hit the end of the cluster map, and we need to do a garbage collect
.garbage_collect:
	call fs_GarbageCollect
	jq .fail ;still make it a fail case for now, until garbage collect actually moves things around
;found an empty cluster
.found:
	ld (ix-3),hl
	ld e,(ix-4)
.len_loop:
	dec e
	jq z,.success
	ld a,(hl)
	inc hl
	inc a
	jq nz,.search_loop ; area not long enough
	dec bc
	ld a,c
	or a,b
	jq nz,.len_loop
	jq .garbage_collect ;we've hit the end of the cluster map, and we need to do a garbage collect
; if we're here, we found a large enough space
.success:
	call sys_FlashUnlock

	ld de,(ix-3)
	dec de
	ld b,(ix-4)
	ld c,(ix-5)
.reserve_loop:
	push bc,de
	ld a,c
	call sys_WriteFlashA
	pop de,bc
	inc de
	djnz .reserve_loop

	call sys_FlashLock

	ld hl,(ix-3)
	ld de,fs_cluster_map
	or a,a
	sbc hl,de ;return first allocated cluster
	dec hl

	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret


