
;-------------------------------------------------------------------------------
; Executable formats
;-------------------------------------------------------------------------------
macro format?.ram?.executable?
	format ram executable at ti.userMem
end macro

macro format?.ram?.executable?.at? addr
	org addr
	db $18,$04,"REX",$00
end macro


macro format?.flash?.executable?
	display "Make sure you're using OffsetInstruction for absolute addressing within your program, or handle relocations appropriately.",$A
	db $18,$04,"FEX",$00
end macro

;-------------------------------------------------------------------------------
; Run instruction offsetting its argument by the pointer to the running program.
; NOTE: Only use this with opcodes that have a 24-bit argument, and do not use opcode suffixes.
;       Furthermore, avoid using this macro unless you have to. It's a lot more expensive than the instruction would otherwise be.
;-------------------------------------------------------------------------------
macro OffsetInstruction? instruction*
	rst $28
	instruction
end macro

;-------------------------------------------------------------------------------
; Software threading instructions
;-------------------------------------------------------------------------------
macro EnableThreading?
	rst $10
	nop
end macro

macro EnableOSThreading?
	rst $10
	rst $28
end macro

macro DisableThreading?
	rst $10
	rst $38
end macro

macro SleepThread?
	rst $10
	halt
end macro

macro WakeThread?
	rst $10
	rst $20
end macro

macro EndThread?
	rst $10
	ret
end macro

macro SpawnThread? start_pc, start_sp
	rst $10
	push bc
	dl start_sp
	dl start_pc
end macro

macro HandleNextThread?
	rst $10
	pop bc
end macro

macro HandleNextThread_IfOSThreading?
	rst $10
	rst $30
end macro

;-------------------------------------------------------------------------------
; OS call defines
;-------------------------------------------------------------------------------
define bos? bos
namespace bos
; jump table
	;
?boot_os                         := $20108
?handle_interrupt                := $2010C
?HandleInstruction               := $20110
;DONOTHING                       := $20114
;DONOTHING                       := $20118
?handle_offsetinstruction        := $2011C
;DONOTHING                       := $20120
;	include 'tiosjt.asm'
;	dd (($022400-$) shr 2) dup $CD or handle_unimplemented shl 8
?sys_ExecuteFile                 := $22400
?os_GetOSInfo                    := $22404
?fs_OpenFile                     := $22408
?fs_GetSectorAddress             := $2240C
?fs_CheckDirExists               := $22410
?fs_CeilDivBySector              := $22414
?fs_CopyFileName                 := $22418
?fs_Read                         := $2241C
?fs_Write                        := $22420
?sys_AddHLAndA                   := $22424
?sys_AnyKey                      := $22428
?sys_FreeAll                     := $2242C
?sys_GetKey                      := $22430
?sys_KbScan                      := $22434
?sys_Malloc                      := $22438
?fs_CreateRamFile                := $2243C
?sys_MemSet                      := $22440
?fs_AllocRam                     := $22444
?sys_WaitKey                     := $22448
?sys_WaitKeyCycle                := $2244C
?gui_DrawConsoleWindow           := $22450
?gui_Input                       := $22454
?gui_NewLine                     := $22458
?gui_Print                       := $2245C
?gui_PrintInt                    := $22460
?gui_Scroll                      := $22464
?gfx_BlitBuffer                  := $22468
?gfx_PrintString                 := $2246C
?_MemClear                       := $22470
?_PushOP1                        := $22474
?_PopOP1                         := $22478
?_Mov9ToOP1                      := $2247C
?_CpHLDE                         := $22480
?_Mov8b                          := $22484
?_ChkFindSym                     := $22488
?_LoadDEInd_s                    := $2248C
?_EnoughMem                      := $22490
?_InsertMem                      := $22494
?_SetHLUTo0                      := $22498
?_PutS                           := $2249C
?_GetCSC                         := $224A0
?_NewLine                        := $224A4
?_ClrScrn                        := $224A8
?_HomeUp                         := $224AC
?_ErrMemory                      := $224B0
?_DrawStatusBar                  := $224B4
?_os_GetSystemInfo               := $224B8
?_UsbPowerVbus                   := $224BC
?_UsbUnpowerVbus                 := $224C0
?sys_EraseFlashSector            := $224C4
?sys_FlashUnlock                 := $224C8
?sys_FlashLock                   := $224CC
?fs_CreateFile                   := $224D0
?strupper                        := $224D4
?strlower                        := $224D8
?fs_AbsPath                      := $224DC
?fs_MultByBytesPerSector         := $224E0
?_LoadLibraryOP1                 := $224E4
?fs_OpenFileInDir                := $224E8
?fs_SetSize                      := $224EC
?fs_WriteFile                    := $224F0
?sys_HLToString                  := $224F4
?fs_DeleteFile                   := $224F8
?_DelVar                         := $224FC
?_CreateVar                      := $22500
?gui_InputNoClear                := $22504
?fs_InitClusterMap               := $22508
?sys_WriteFlash                  := $2250C
?sys_WriteFlashA                 := $22510
?sys_JoinArgv                    := $22514
?fs_PathLen                      := $22518
?fs_ParentDir                    := $2251C
?fs_StrToFileEntry               := $22520
?fs_DirList                      := $22524
?sys_Free                        := $22528
?sys_CallExecuteFile             := $2252C
?sys_JumpExecuteFile             := $22530
?sys_OpenDevice                  := $22534
?fs_CopyFile                     := $22538
;DONOTHING                       := $2253C
;DONOTHING                       := $22540
;DONOTHING                       := $22544
?fs_GetSector                    := $22548
?fs_WriteByte                    := $2254C
?fs_RenameFile                   := $22550
?_SetCursorPos                   := $22554
?fs_CreateDir                    := $22558
?gfx_BufClear                    := $2255C
?gfx_LcdClear                    := $22560
?fs_SanityCheck                  := $22564
?sys_SetupOnInterruptHandler     := $22568
?gui_PrintChar                   := $2256C
?gfx_SetDraw                     := $22570
?gui_PrintString                 := $22574
?gui_PrintLine                   := $22578
?gui_PrintUInt                   := $2257C
;DONOTHING                       := $22580
;DONOTHING                       := $22584
?fs_GetFilePtr                   := $22588
;DONOTHING                       := $2258C
?sys_ExecuteFileHL               := $22590
?sys_TurnOff                     := $22594
?sys_NextProcessId               := $22598
?sys_PrevProcessId               := $2259C
?sys_FreeProcessId               := $225A0
?fs_GarbageCollect               := $225A4
?gfx_SwapTextColors              := $225A8
?fs_WriteNewFile                 := $225AC
?gfx_SetFont                     := $225B0
?gfx_SetDefaultFont              := $225B4
?sys_FreeRunningProcessId        := $225B8
?util_Zx7Decompress              := $225BC
?sys_CheckMallocRAM              := $225C0
?gfx_Compute                     := $225C4
?gfx_FillRectangle               := $225C8
?gfx_FillScreen                  := $225CC
?gfx_GetFontPtr                  := $225D0
?gfx_HorizLine                   := $225D4
?gfx_InitStdPalette              := $225D8
?gfx_NextLine                    := $225DC
?gfx_PrintChar                   := $225E0
?gfx_PrintHexA                   := $225E4
?gfx_PrintUInt                   := $225E8
?gfx_Rectangle                   := $225EC
?gfx_Set8bpp                     := $225F0
?gfx_Set16bpp                    := $225F4
?gfx_SetTextXY                   := $225F8
?gfx_Sprite                      := $225FC
?gfx_Sprite2x                    := $22600
?gfx_VertLine                    := $22604
?sys_Malloc32Align32             := $22608
?sys_Malloc64Align256            := $2260C
?gfx_PrintStringXY               := $22610
?gfx_GetTextX                    := $22614
?gfx_GetTextY                    := $22618
;DONOTHING                       := $2261C
;DONOTHING                       := $22620
?sys_OpenFileInPath              := $22624
?sys_VarString                   := $22628
?fs_GetFreeSpace                 := $2262C
?fs_GetFDPtr                     := $22630
?fs_GetFDLen                     := $22634
?_OP1ToPath                      := $22638
?th_WaitKeyCycle                 := $2263C
?fs_JoinPath                     := $22640
?sys_MallocPersistent            := $22644
?sys_OpenFileInVar               := $22648
?fs_BaseName                     := $2264C
?fs_MoveFile                     := $22650
?fs_WriteRaw                     := $22654
?_UnpackUpdates                  := $22658
?sys_ReadSectorCache             := $2265C
?sys_WriteSectorCache            := $22660
?sys_OpenFileInLib               := $22664
; end of jump table
;-------------------------------------------------------------------------------
; OS memory areas and misc defines
;-------------------------------------------------------------------------------
?LCD_PAL?    := 0E30200h
?LCD_CTRL?   := 0E30018h
?LCD_VRAM?   := 0D40000h
?LCD_BUFFER? := LCD_VRAM + LCD_WIDTH*LCD_HEIGHT
?LCD_WIDTH?  := 320
?LCD_HEIGHT? := 240
?LCD_8BPP?   := $27
?LCD_16BPP?  := $2D
?TEXT_MAX_ROW    := 231
?RAM_START  := 0D00000h
?flag_start             := $D00000
?currow?                := ti.curRow
?curcol?                := ti.curCol
?console_col            := curcol
?console_line           := currow
?color_primary          := ti.drawFGColor      ; 1 byte
?lcd_bg_color           := ti.drawFGColor+1    ; 1 byte
?lcd_text_fg            := ti.textFGcolor      ; 1 byte
?lcd_text_bg            := ti.textFGcolor+1    ; 1 byte
?lcd_text_fg2           := ti.textBGcolor      ; 1 byte
?lcd_text_bg2           := ti.textBGcolor+1    ; 1 byte
?cursor_color           := ti.statusBarBGColor ; 1 byte
?font_data              := ti.lFont_record
?font_spacing           := ti.lFont_record+3
?lcd_x                  := ti.lFont_record+6
?lcd_y                  := ti.lFont_record+9
?remaining_free_RAM     := ti.appData    ; 3 bytes
?op_stack_ptr           := ti.appData+3  ; 3 bytes
?on_interrupt_jump      := ti.appData+6  ; jump byte for on_interrupt_handler
?on_interrupt_handler   := ti.appData+7  ; 3 bytes. Jump to on key interrupt handler. Byte preceeding this should be $C3 or $C9
?cur_lcd_buffer         := ti.appData+10 ; 3 bytes. Points to current LCD draw buffer
?running_process_id     := ti.appData+13 ; 1 byte. Current process ID (used for per-program memory allocation)
?ScrapMem2              := ti.appData+14 ; 3 bytes
?top_of_UserMem         := ti.appData+17 ; 3 bytes
?LastCommandResult      := ti.appData+20 ; 4 bytes. Stores result of previously executed command
?ExecutingFileFd        := ti.appData+24 ; 3 bytes. Pointer to currently executing file descriptor. -1 if file not found. 0 if file descriptor is not applicable
?running_program_ptr    := ti.appData+27 ; 3 bytes. Stores pointer to currently running program
?return_code_flags      := ti.appData+30 ; flag byte that determines how to interpret the return value of the last run program. Is to be set within the program for non-default return interpretation.
?flashStatusByte        := ti.appData+31 ; 1 byte
?filesystem_driver      := ti.appData+32 ; 1 byte
?copy_buffer            := ti.appData+33 ; 3 bytes, points to first copy buffer entry, or -1 if nothing is stored.
?threading_enabled      := ti.appData+36 ; 1 byte, determines if software threading is enabled and whether it should be used in OS routines
?current_thread         := ti.appData+37 ; 1 byte, currently running thread ID
?gfx_string_temp        := ti.appData+38 ; 16 bytes, temp location for integer printing
?saved_LcdUpbase        := ti.appData+54 ; 3 bytes, saves LcdUpbase during sector caching
?ScrapByte              := ti.flashByte
?ScrapWord              := ti.scrapMem
?ScrapMem               := ti.scrapMem
?last_keypress          := ti.kbdScanCode ; 1 byte. Last keypress returned by an os getkey routine
?asm_prgm_size          := ti.asm_prgm_size ;3 bytes
?SaveSP                 := ti.errSP ; 3 bytes, saves SP when running programs.
?fsOP1                  := ti.OP1
?fsOP2                  := ti.OP2
?fsOP3                  := ti.OP3
?fsOP4                  := ti.OP4
?fsOP5                  := ti.OP5
?fsOP6                  := ti.OP6
?safeRAM                := ti.pixelShadow ; 69090 bytes scrap RAM
?safeRAM_len            := 69090
?usbArea                := ti.usbArea ; 14306 bytes used for usb, probably need to disable timer3/usb interrupts to use
?usbHandleKeys          := ti.usbHandleKeys ; zero this byte while using usbArea to keep GetCSC from affecting other parts of usbArea
?usbInited              := ti.usbInited ; zero this byte while using usbArea and to reset the usb stack when interrupts are re-enabled
?heapBot                := ti.heapBot
?ramCodeTop             := ti.ramCodeTop
?reservedRAM            := ti.ramCodeTop
?bos_UserMem            := $D1A881
?end_of_usermem         := libload_bottom_ptr-2
?libload_bottom_ptr     := libload_top_ptr-$3FE ; 1022 bytes for executing libload
?libload_top_ptr        := thread_temp_save-$400
?op_stack_bot           := thread_temp_save-$400
?op_stack_top           := thread_temp_save-$300 ;256 bytes downward
?current_working_dir    := thread_temp_save-$200
?InputBuffer            := thread_temp_save-$100
?thread_temp_save       := $D2F000 ; temporary save location for registers when a thread switch is triggered. 16 bytes per thread, 256 threads = 4096 bytes.
?malloc_cache           := $D2F800 ; 4096 bytes
?thread_map             := $D30000 ; thread map. 256 threads. Active threads have bit 7 set.
?thread_parents         := $D30100 ; 256 bytes, one per thread. Saves ID of thread that spawned a given thread. A thread will only be run if it's parent thread is awake
?bottom_of_malloc_RAM   := $D30200
?top_of_vat             := top_of_RAM
?top_of_RAM             := $D40000
?start_of_user_archive  := $040000 ;sector $04
?fs_root_dir_lba := $010000 shr 9
?fs_root_dir_address := start_of_user_archive + $010000
?end_of_user_archive    := $3B0000 ;sector $3B, start of certificate
?fs_cluster_map := $3BE000
?fs_cluster_map.len := 7040
?fs_cmap_length := fs_cluster_map.len
?fs_sector_size                := 512
?fscluster_smallallocblocksize := 1024
?fs_partition_desc_size        := 16
?fs_file_desc_size             := 16
?fscluster_freed             := $00
?fscluster_allocated         := $FE
?fscluster_clean             := $FF
?fd_executable := 0
?fd_hidden     := 1
?fd_system     := 2
?fd_subfile    := 3
?fd_subdir     := 4
?fd_device     := 5
?fd_link       := 6
?fd_elevated   := 7
?fsentry_deleted         := $00
?fsentry_dot             := $2E
?fsentry_longfilename    := $F1
?fsentry_unlisted        := $F2
?fsentry_dirextender     := $FF
?fsentry_endofdir2       := $FF
?fsentry_filename            := $00
?fsentry_filename.len        := 8
?fsentry_fileext             := $08
?fsentry_fileext.len         := 3
?fsentry_fileattr            := $0B
?fsentry_fileattr.len        := 1
?fsentry_filesector          := $0C
?fsentry_filesector.len      := 2
?fsentry_filelen             := $0E
?fsentry_filelen.len         := 2
?device_Header               := 0
?device_Flags                := 1
?device_Type                 := 2
?device_Version              := 3
?device_JumpTable            := 4 ; jump table for device functions
?device_JumpInit             := 4
?device_JumpDeinit           := 8
?device_JumpRead             := 12
?device_JumpWrite            := 16
?device_JumpGetDMA           := 20
?device_CodeStart            := 24
?device_Header.len           := 4
?device_Flags.len            := 1
?device_Type.len             := 1
?device_Version.len          := 1
?device_JumpTable.len        := 5*4 ; jump table for device functions
?bDeviceWritable             := 7
?bDeviceReadable             := 6
?bDeviceHasDMA               := 5
?bDeviceDMAWritable          := 4
?bDeviceDMAReadable          := 3
?bDeviceNeedsInit            := 2
?bDeviceNeedsDeinit          := 1
?devtSoftware                := $00
?devtMemory                  := $04
?devtMMIO                    := $08
?devtUSB                     := $10
?devtMSD                     := $14
?devtMSDFS                   := $15
?devtMSDFAT32                := $16
?threadMallocStackSize       := 512
?threadsDisabled             := 0
?threadsEnabled              := 1
?threadOSRoutines            := 2
?threadPrograms              := 3
?threadAlways                := 250
?bThreadAlive                := 7
?bThreadPersistent           := 6
?bThreadSleeping             := 5
?bIsFlashUnlocked     := 0
?bKeepFlashUnlocked   := 1
?mIsFlashUnlocked     := 1
?mKeepFlashUnlocked   := 2
?bReturnNotError      := 0
?bReturnHex           := 1
?bReturnLong          := 2
?bSilentReturn        := 3

end namespace