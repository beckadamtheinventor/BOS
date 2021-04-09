


fs_Format:
	ld hl,str_Formatting
	call gui_DrawConsoleWindow

	ld hl,flashStatusByte
	set bKeepFlashUnlocked, (hl)
	call sys_FlashUnlock

	ld a,$04
.erase_loop: ;erase all filesystem flash sectors
	push af
	call sys_EraseFlashSector
	xor a,a
	ld (curcol),a
	ld hl,str_ErasingSector
	call gui_Print
	pop af
	push af
	call gfx_PrintHexA
	call gfx_BlitBuffer
	pop af
	inc a
	cp a,end_of_user_archive shr 16
	jr nz,.erase_loop

	ld hl,str_ErasedUserMemory
	call gui_PrintLine

	ld hl,str_WritingFilesystem
	call gui_PrintLine
	
	ld bc,fs_drive_a_data_compressed_bin
	push bc
	ld bc,$040000
	push bc
	call util_Zx7DecompressToFlash
	pop bc,bc

	call fs_InitClusterMap
	ld hl,flashStatusByte
	res bKeepFlashUnlocked, (hl)
	call sys_FlashLock
	ld hl,str_PressAnyKey
	call gui_Print
	jp sys_WaitKeyCycle


