
	jq boot_main
	db "FEX",0
boot_main:
	call bos.os_GetOSInfo
	call bos.gui_DrawConsoleWindow
	call bos.fs_SanityCheck
	ld hl,str_ClusterMapFile
	push hl
	call bos.fs_OpenFile
	ld bc,$C
	add hl,bc
	ld hl,(hl)
	ex (sp),hl
	call bos.fs_GetSectorAddress
	pop bc
	ld a,(hl)
	cp a,$FE
	jq nz,.init_cmap
.start:
	call bos.sys_GetKey
	cp a,53
	ret z
	ld bc,str_UsrBootFile
	push bc
	call bos.fs_OpenFile
	ld hl,$FF0000
	ex (sp),hl
	push hl
	call nc,bos.sys_ExecuteFile
	ld hl,str_UsrExplorerFile
	ex (sp),hl
	call bos.fs_OpenFile
	jq nc,.run_user_explorer
	ld hl,str_ExplorerExecutable
	ex (sp),hl
	call bos.fs_OpenFile
	jq c,boot_fail
.run_user_explorer:
	call bos.sys_ExecuteFile
	pop bc
	pop bc
	ret
.init_cmap:
	call bos.fs_InitClusterMap
	ld hl,str_PressAnyKey
	call bos.gui_Print
	call bos.sys_WaitKeyCycle
	jq .start

boot_fail:
	pop bc,bc
	ld hl,str_BootFailedNoExplorer
	call bos.gui_DrawConsoleWindow
	jq bos.sys_WaitKey

str_PressAnyKey:
	db $A,"Press any key to continue.",$A,0
str_BootFailedNoExplorer:
	db "Boot failed. /bin/explorer.bin not found!",$A
	db "Press any key to open recovery menu.",$A,0
str_CmdExecutable:
	db "/bin/cmd.bin",0
str_ExplorerExecutable:
	db "/bin/explorer.bin",0
str_ClusterMapFile:
	db "/dev/cmap.dat",0
str_UsrBootFile:
	db "/boot/usr/onboot.bin",0
str_UsrExplorerFile:
	db "/boot/usr/explorer.bin",0
