
fs_ExtractOSBinaries:
	ld hl,str_ExtractingOSBinaries
	call gui_PrintLine
.silent:
	call sys_FlashUnlock
	ld a,fs_filesystem_address shr 16
	call sys_EraseFlashSector
	ld hl,str_bosfs512_partition_header
	ld bc,str_bosfs512_partition_header.len
	ld de,fs_filesystem_address
	call sys_WriteFlash

	ld bc,fs_drive_a_data_compressed_bin
	push bc
	ld bc,fs_filesystem_address+512
	push bc
	call util_Zx7DecompressToFlash
	pop bc,bc
	jq sys_FlashLock