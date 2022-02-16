;@DOES initialize cluster map given data within the file system.
;@INPUT void fs_InitClusterMap(void);
;@NOTE uses the first half of vRam as scrap.
fs_InitClusterMap:
	ld a,(fs_cluster_map)
	cp a,fscluster_allocated
	ret z ; dont build the cluster map if its already been built
.reinit:
	ld a,fs_cluster_map shr 16
	call sys_ReadSectorCache.entry
	ld hl,fs_cluster_map
	push hl
	pop de
	inc de
	ld bc,fs_cluster_map.len - 1
if fscluster_clean = $FF
	if ~fs_cluster_map.len and $FF
		ld (hl),c
	else
		ld (hl),fscluster_clean
	end if
else
	ld (hl),fscluster_clean
end if
	ldir

.dont_clean_up:
	ld a,fscluster_allocated
	ld (ti.vRam + (fs_cluster_map and $FFFF)),a
	push iy
	ld iy,$040000
	call .traverse_into_jump
	pop iy

	ld a,fs_cluster_map shr 16
	jq sys_WriteSectorCache.entry

.traverse:
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
	jq z,.regular_file
	ld hl,(iy+fsentry_filesector)
	ex.s hl,de
	lea hl,iy
	ld l,0
	res 0,h
	add hl,de
	ld de,-$040000
	add hl,de
	call fs_CeilDivBySector
	ld de,fs_cluster_map
	add hl,de
	push hl
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	pop de
	ld b,l
	jq .mark_file_entry
.regular_file:
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld b,l
	ld de,(iy+fsentry_filesector)
	ex.s hl,de
	ld de,ti.vRam + (fs_cluster_map and $FFFF)
	add hl,de
	ex hl,de
.mark_file_entry:
	ld a,fscluster_allocated
	bit fd_subdir, (iy+fsentry_fileattr)
	jr z,.not_a_directory
	ld (de),a
	call .traverse_into
	jr .traverse_next
.not_a_directory:
	push iy
.mark_file_loop:
	ld (de),a
	inc de
	djnz .mark_file_loop
	pop iy
.traverse_next:
	lea iy,iy+16
	jq .traverse
.traverse_into:
	push iy
	call .traverse_into_jump
	pop iy
	ret
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

