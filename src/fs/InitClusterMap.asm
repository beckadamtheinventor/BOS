;@DOES initialize cluster map given data within the file system.
;@INPUT void fs_InitClusterMap(void);
;@NOTE uses the first half of vRam as scrap.
fs_InitClusterMap:
	ld hl,fs_cluster_map
	ld a,(hl)
	cp a,fscluster_allocated
	jr nz,.reinit
; Check if the cluster map is all allocated, all free, or contains any invalid entries.
; Rebuild the cluster map if needed.
	ld bc,fs_cluster_map.len
; if fs_cluster_map.len and $FF
	; ld de,0
; else
	; ld e,c
	; mlt de
; end if
.checkloop:
	dec bc
	ld a,c
	or a,b
	ret z
	; jr nz,.continuecheckloop
	; ld a,e
	; or a,d
	; ret nz
	; ld a,e
; if fs_cluster_map.len and $FF
	; ld a,e
	; cp a, fs_cluster_map.len and $FF
; else
	; or a,e
; end if
	; ret nz
	; ld a,d
	; cp a, fs_cluster_map.len shr 8
	; jr z,.reinit
	; ret
; .continuecheckloop:
	ld a,(hl)
	or a,a
	jr z,.checkloop
	inc hl
	inc a
	jr z,.checkloop
	; inc de
	inc a
	jr z,.checkloop
.reinit:
	ld a,fs_cluster_map shr 16
	call sys_ReadSectorCache.entry
	ld hl,ti.vRam + (fs_cluster_map and $FFFF)
	push hl
	pop de
	inc de
	ld bc,fs_cluster_map.len - 1
	ld (hl),fscluster_clean
	ldir

.dont_clean_up:
	push iy
	ld hl,ti.vRam + (fs_cluster_map and $FFFF)
	ld a,fscluster_allocated
	ld bc, fs_root_dir_lba
	push hl
	pop de
	inc de
	ld (hl),a
	ldir
	ld hl,ti.vRam + (fs_cluster_map and $FFFF) + fs_root_dir_lba
	ld b,fs_directory_size*2/fs_sector_size
.mark_root_dir:
	ld (hl),a
	inc hl
	djnz .mark_root_dir

	ld iy,start_of_user_archive
	call .traverse_into_jump
	pop iy

	ld a,fs_cluster_map shr 16
	call sys_WriteSectorCache.entry
	xor a,a
	ret

.traverse:
	lea hl,iy
	ld a,l
	and a,fs_sector_size - 1
	jr nz,.not_at_start_of_sector
	ld de,-start_of_user_archive
	add hl,de
	call fs_CeilDivBySector
	ld de,ti.vRam + (fs_cluster_map and $FFFF)
	add hl,de
	ld (hl),fscluster_allocated
.not_at_start_of_sector:
	ld a,(iy)
	or a,a
	jq z,.traverse_next
	inc a
	ret z
	inc a
	jq z,.traverse_into_jump
	cp a,'.'+2
	jq z,.traverse_next
	bit fd_subfile, (iy+fsentry_fileattr)
	jr z,.regular_file
	ld hl,(iy+fsentry_filesector)
	ex.s hl,de
	lea hl,iy
	ld a,l
	and a,fs_sector_size - 1
	ld l,a
	add hl,de
	ld de,-start_of_user_archive
	add hl,de
	call fs_CeilDivBySector
	ld de,ti.vRam + (fs_cluster_map and $FFFF)
	add hl,de
	push hl
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld c,l
	ld b,h
	pop hl
	jr .mark_file_entry
.regular_file:
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld c,l
	ld b,h
	ld de,(iy+fsentry_filesector)
	ex.s hl,de
	ld de,ti.vRam + (fs_cluster_map and $FFFF)
	add hl,de
.mark_file_entry:
	push iy
.mark_file_loop:
	ld (hl),fscluster_allocated
	inc hl
	dec bc
	ld a,b
	or a,c
	jr nz,.mark_file_loop
	; ex hl,de
	pop iy
	bit fd_subdir, (iy+fsentry_fileattr)
	jr z,.traverse_next
	push iy
	call .traverse_into_jump
	pop iy
.traverse_next:
	lea iy,iy+fs_file_desc_size
	jq .traverse
.traverse_into_jump:
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	ex.s hl,de
	ld hl,ti.vRam + (fs_cluster_map and $FFFF)
	add hl,de
	ld (hl),fscluster_allocated
	jq .traverse

