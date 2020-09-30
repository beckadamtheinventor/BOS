
	jp boot_os
	jp handle_interrupt
	jp DONOTHING ;handle_rst10
	jp DONOTHING ;handle_rst18
	jp DONOTHING ;handle_rst20
	jp DONOTHING ;handle_rst28
	jp DONOTHING ;handle_rst30
	jp sys_ExecuteFile
	jp sys_ExecuteFileEntryPoint
	jp fs_OpenFile
	jp fs_GetClusterPtr
	jp fs_CheckDirExists
	jp fs_GetPathLastName
	jp fs_CopyFileName
	jp fs_Read
	jp sys_AddHLAndA
	jp sys_AnyKey
	jp sys_FreeAll
	jp sys_GetKey
	jp sys_KbScan
	jp sys_Malloc
	jp sys_MemCmp
	jp sys_MemSet
	jp sys_Mult24x8
	jp sys_WaitKey
	jp sys_WaitKeyCycle
	jp gui_DrawConsoleWindow
	jp gui_Input
	jp gui_NewLine
	jp gui_Print
	jp gui_PrintInt
	jp gui_Scroll
	jp gfx_BlitBuffer
	jp gfx_PrintString

