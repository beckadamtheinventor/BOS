
boot_os:
	call gfx_SetDefaultFont
	call gfx_Set8bpp
	call fs_SanityCheck
	ld a,'C'
	call fs_RootDir
	ld de,current_working_dir
	call fs_CopyFileName
os_return:
	call gfx_Set8bpp
	ld hl,current_working_dir
	call gui_DrawConsoleWindow
	ld hl,str_Prompt
	call gfx_PrintString
	call gfx_BlitBuffer
os_main:
	
enter_input:
	ld bc,255
	push bc
	ld bc,InputBuffer
	push bc
	call gui_Input
	pop hl
	pop bc
	
	
	jq os_main
