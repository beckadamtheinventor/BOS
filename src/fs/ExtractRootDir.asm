
fs_ExtractRootDir:
	call fs_SanityCheck.check_root
	ret z ; don't re-init the root directory if it's already initialized
	ld a,fs_root_dir_address shr 16
	call sys_ReadSectorCache.entry
	ex hl,de
	ld hl,fs_root_dir_data
	ld bc,fs_root_dir_data.len
	ldir
	ld hl,fs_directory_size*2-16-fs_root_dir_data.len
	add hl,de
	ld (hl),$FE ; write end-of-directory marker
	ld a,fs_root_dir_address shr 16
	jq sys_WriteSectorCache.entry
