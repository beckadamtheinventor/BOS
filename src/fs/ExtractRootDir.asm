
fs_ExtractRootDir:
	call fs_SanityCheck.check_root
	ret z ; don't re-init the root directory if it's already initialized
	ld a,fs_root_dir_address shr 16
	call sys_ReadSectorCache.entry
	ex hl,de
	ld hl,fs_root_dir_data
	ld bc,fs_root_dir_data.len
	ldir
	ld a,fs_root_dir_address shr 16
	jq sys_WriteSectorCache.entry
