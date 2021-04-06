
	jq boot_main
	db "FEX",0
boot_main:
	ld a,1
	call bos.gfx_SetDraw
	xor a,a
	ld (bos.lcd_text_bg),a
	dec a
	ld (bos.lcd_text_fg),a
	call bos.os_GetOSInfo
	call bos.gui_DrawConsoleWindow
	ld hl,str_Booting
	call bos.gui_PrintLine
	call bos.sys_GetKey
	cp a,53
	ret z
	call bos.fs_SanityCheck
	call bos.sys_GetKey
	cp a,53
	ret z
	ld hl,str_HomeDir
	ld e,1 shl bos.fd_subdir
	push de,hl
	call bos.fs_CreateDir
	pop hl,bc
	call bos.sys_GetKey
	cp a,53
	ret z
	ld bc,str_BootConfigFile
	push bc
	call bos.fs_OpenFile
	pop bc
	call c,generate_boot_configs
	jq c,boot_fail

	;TODO - interpret config file

	call bos.sys_GetKey
	cp a,53
	ret z

	ld bc,$FF0000
	push bc
	ld bc,str_ExplorerExecutable
	push bc
	call bos.fs_OpenFile
	jq c,boot_fail
	call bos.sys_FreeAll
	call bos.sys_ExecuteFile
	pop bc
	pop bc
	ret

generate_boot_configs:
	push bc
	ld bc,str_EtcConfigDir
	ld e,1 shl bos.fd_subdir
	push de,bc
	call bos.fs_CreateDir
	ld hl,str_EtcConfigBootDir
	ex (sp),hl
	call bos.fs_CreateDir
	pop bc
	ld hl,.onbootconfig_len
	ex (sp),hl
	ld hl,.onbootconfig
	ld e,0
	ld bc,str_BootConfigFile
	push hl,de,bc
	call bos.fs_WriteNewFile
	pop bc,bc,bc,bc
	call bos.sys_FreeAll
	call bos.fs_OpenFile
	pop bc
	ret
.onbootconfig:
	db "#TODO, NOT YET IMPLEMENTED.",$A
	db "login",$A
	db "#insert boot-time programs to run here",$A
	db $A
	db "#dont remove this line",$A
	db "explorer",$A
.onbootconfig_len:=$-.onbootconfig


boot_fail:
	pop bc,bc
	ld hl,str_BootFailed
	call bos.gui_DrawConsoleWindow
	jq bos.sys_WaitKey

str_Booting:
	db "Starting up...",$A,0
str_PressAnyKey:
	db $A,"Press any key to continue.",$A,0
str_BootFailed:
	db "Boot has encountered a critical error",$A
	db "and cannot complete boot process.",$A
	db "Press any key to open recovery options.",$A,0
str_CmdExecutable:
	db "/bin/cmd",0
str_ExplorerExecutable:
	db "/bin/explorer",0
str_ClusterMapFile:
	db "/dev/cmap.dat",0
str_EtcConfigDir:
	db "/etc/config",0
str_EtcConfigBootDir:
	db "/etc/config/boot",0
str_BootConfigFile:
	db "/etc/config/boot/onboot.cmd",0
str_HomeDir:
	db "/home",0
