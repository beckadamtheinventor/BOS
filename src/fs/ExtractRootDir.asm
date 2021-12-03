fs_ExtractRootDir:
	ld a,(fs_root_dir_address)
	inc a
	ret nz
	call sys_FlashUnlock
	ld hl,fs_root_dir_data
	ld bc,fs_root_dir_data.len
	ld de,fs_root_dir_address
	call sys_WriteFlash
	jq sys_FlashLock
