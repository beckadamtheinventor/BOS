	jq uninstall_main
	db "FEX",0
uninstall_main:
	ld hl,.are_you_sure
	call bos.gui_DrawConsoleWindow
	call bos.sys_WaitKey
	cp a,9
	ret nz
	call bos.sys_FlashUnlock
	ld a,$02
	call bos.sys_EraseFlashSector
	rst $08
.are_you_sure:
	db "Are you sure?",$A
	db "This will erase BOS and all user data currently in the filesystem.",$A
	db "Press [enter] to confirm",$A,0

