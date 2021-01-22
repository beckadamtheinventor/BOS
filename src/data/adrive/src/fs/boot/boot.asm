
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
	ld a,50
	call ti.DelayTenTimesAms
.start:
	call bos.sys_GetKey
	cp a,53
	ret z
	ld bc,str_ExplorerExecutable
	push bc
	call bos.fs_OpenFile
	jq c,boot_fail
	ld hl,$FF0000
	ex (sp),hl
	push hl
	call bos.sys_ExecuteFile
	pop bc
	pop bc
	ret
.init_cmap:
	call bos.fs_InitClusterMap
	jq .start

boot_fail:
	pop bc
	ld hl,str_BootFailedNoExplorer
	call bos.gui_DrawConsoleWindow
	jq bos.sys_WaitKey

str_BootFailedNoExplorer:
	db "Boot failed. /bin/explorer.exe not found!",$A
	db "Press any key to open recovery menu.",$A,0
str_CmdExecutable:
	db "/bin/cmd.exe",0
str_ExplorerExecutable:
	db "/bin/explorer.exe",0
str_ClusterMapFile:
	db "/dev/cmap.dat",0

