
fs_ExtractOSBinaries:
	ld hl,str_ExtractingOSBinaries
	call gui_PrintLine
.silent:
	call sys_FlashUnlock
	ld a,start_of_user_archive shr 16
	call sys_EraseFlashSector
	ld hl,str_bosfs512_partition_header
	ld bc,str_bosfs512_partition_header.len
	ld de,start_of_user_archive
	call sys_WriteFlash

	ld hl,fs_drive_a_data_compressed_bin
	; ld a,(hl)
	; inc hl
	push hl
	ld bc,start_of_user_archive+fs_directory_size
	push bc
	; cp a,'0'
	; jr z,.zx0
	call util_Zx7DecompressToFlash
	; jr .done
; .zx0:
	; call util_Zx0DecompressToFlash
; .done:
	pop bc,bc
	jq sys_FlashLock