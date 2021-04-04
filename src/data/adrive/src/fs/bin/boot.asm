
	jq boot_main
	db "FEX",0
boot_main:
	ld a,1
	call bos.gfx_SetDraw
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
	ld bc,str_BootConfigFile
	push bc
	call bos.fs_OpenFile
	pop bc
	call c,generate_boot_configs
	ld bc,$C
	ld de,(hl)
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	push bc,de
	call bos.fs_GetSectorAddress
	pop bc,bc

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
	pop bc,bc
	ld hl,.onbootconfig_len
	ld e,0
	ld bc,str_BootConfigFile
	push hl,de,bc
	call bos.fs_CreateFile
	pop bc,bc,bc
	ld de,0
	push de,hl ;offset, file descriptor
	ld bc,.onbootconfig_len
	ld e,1
	push de,bc ;count, len
	ld hl,.onbootconfig
	push hl
	call bos.fs_Write
	pop bc,bc,bc,bc,bc
	call bos.sys_FreeAll
	call bos.fs_OpenFile
	pop bc
	ret
.onbootconfig:
	db "#TODO, NOT YET IMPLEMENTED.",$A
	db "#Modify the following lines to control what programs run on boot.",$A
	db "explorer",$A
.onbootconfig_len:=$-.onbootconfig


boot_fail:
	pop bc,bc
	ld hl,str_BootFailedNoExplorer
	call bos.gui_DrawConsoleWindow
	jq bos.sys_WaitKey

str_Booting:
	db "Starting up...",$A,0
str_PressAnyKey:
	db $A,"Press any key to continue.",$A,0
str_BootFailedNoExplorer:
	db "Boot failed. /bin/explorer not found!",$A
	db "Press any key to open recovery menu.",$A,0
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
	db "/etc/config/boot/onboot.cfg",0
