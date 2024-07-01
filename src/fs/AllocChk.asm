
;@DOES Check if a memory block can be allocated in flash
;@INPUT unsigned int fs_AllocChk(unsigned int len);
;@OUTPUT hl = first sector that would be allocated, or -1 and Cf set if failed.
fs_AllocChk:
	ld hl,-6
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-6),hl
.entry:
	ld hl,(ix+6)
	call fs_CeilDivBySector
	ld (ix-6),hl

	ld hl,fs_cluster_map + fs_root_dir_lba ; only check clusters following the filesystem root directory
	ld bc,fs_cluster_map.len - fs_root_dir_lba
	call fs_IsOSBackupPresent
	jr z,.search_loop
	; if an OS backup is present, we should not allocate within its bounds.
	; basically cluster map length minus root directory cluster minus the number of clusters reserved to the OS backup
	ld bc, fs_cluster_map.len - (($3B0000-fs_os_backup_location) shr fs_sector_size_bits) - fs_root_dir_lba
.search_loop:
	ld a,(hl)
	inc hl
assert fscluster_clean = $FF
	inc a
	jr z,.found
	dec bc
	ld a,c
	or a,b
	jr nz,.search_loop
	jq .fail ; we've hit the end of the cluster map
; found an empty cluster
.found:
	ld (ix-3),hl
	ld de,(ix-6)
.len_loop:
	dec de
	ld a,e
	or a,d
	jr z,.success
	ld a,(hl)
	inc hl
	inc a
	jr nz,.search_loop ; area not long enough
	dec bc
	ld a,c
	or a,b
	jr nz,.len_loop
	jr .fail ; we've hit the end of the cluster map
; if we're here, we found a large enough space
.success:
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


