


fs_Format:
	ld hl,str_Formatting
	call gui_DrawConsoleWindow

	call flash_unlock

	ld a,$04
.erase_loop: ;erase all system and user flash sectors
	push af
	call sys_EraseFlashSector
	ld hl,str_ErasingSector
	call gui_Print
	pop af
	push af
	call gfx_PrintHexA
	call gfx_BlitBuffer
	pop af
	inc a
	cp a,$3B
	jr nz,.erase_loop

	ld hl,str_ErasedUserMemory
	call gui_Print

	ld hl,str_WritingFilesystem
	call gui_Print
	
	ld hl,fs_drive_a_data_compressed_bin
	push hl
	ld hl,$040000
	push hl
	call util_Zx7DecompressToFlash
	pop hl,hl

	call flash_lock
	ld hl,str_PressAnyKey
	call gui_Print
	jp sys_WaitKeyCycle

