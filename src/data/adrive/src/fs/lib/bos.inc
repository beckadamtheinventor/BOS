

;-------------------------------------------------------------------------------
; Executable formats
;-------------------------------------------------------------------------------
macro ram_executable?
	ram_executable_at ti.userMem
end macro

macro ram_executable_at? addr
	org addr
	db $18,$04,"REX",$00
end macro

macro flash_executable? header:1
	local flashexecbase
	element flashexecbase
	virtual at flashexecbase
		if header = 1
			db $18,$04,"FEX",$00
		end if
	macro end?.flash_executable?
		purge ?
		purge end?.flash_executable?
		local prgmdata, prgmlen
		prgmlen := $-$$
		load prgmdata: $-$$ from $$
		end virtual
		db prgmdata
	end macro
	macro ? line&
		match opcode= args, line
			if `opcode = "call" | `opcode = "jp" | `opcode = "jq" | `opcode = "ld" | `opcode = "syscall"
				match lhs=,rhs, args
					match (val), lhs
						if val relativeto flashexecbase
							rst $28
							opcode (0), rhs
							store val - $ : 3 at $ - 3
						else
							opcode (val), rhs
						end if
					else match (val), rhs
						if val relativeto flashexecbase
							rst $28
							opcode lhs, (0)
							store val - $ : 3 at $ - 3
						else
							opcode lhs, (val)
						end if
					else if rhs relativeto flashexecbase
						rst $28
						opcode lhs, 0
						store rhs - $ : 3 at $ - 3
					else
						opcode lhs, rhs
					end if
				else match opcode= lhs, line
					match (val), lhs
						opcode lhs
					else if lhs relativeto flashexecbase
						rst $28
						opcode 0
						store lhs - $ : 3 at $ - 3
					else
						opcode lhs
					end if
				else
					opcode lhs,rhs
				end match
			else if args relativeto flashexecbase
				opcode args - flashexecbase
			else
				opcode args
			end if
		else
			line
		end match
	end macro
end macro

;-------------------------------------------------------------------------------
; Syscall instruction macro
;-------------------------------------------------------------------------------
; lbl should point to a string containing the syscall path
; example:
;	syscall gfx_PrintString
;	...
;	gfx_PrintString:
;		db "gfx/PrintString",0
macro syscall? lbl
	rst $18
	dl lbl - $+3
end macro

;-------------------------------------------------------------------------------
; Syscall library macro
;-------------------------------------------------------------------------------
macro syscalllib? sclname
	local exports
	local flashexecbase
	element flashexecbase
	virtual
		exports.area::
	end virtual
	virtual as "h"
		header.area::
	end virtual
	virtual as "src"
		symbols.area::
	end virtual
	virtual at flashexecbase-5
	db "SCL",0
	macro export? routine, name, hname, hdef&
		virtual exports.area
			if defined routine.ramroutine
				db 2
			else
				db 1
			end if
			dw routine-flashexecbase
			db name, 0
		end virtual
		virtual header.area
			db hdef
			db $A
		end virtual
		virtual symbols.area
			db "public _", hname,$A
			db '_',hname,' := syscall "',sclname,'/',name,'"',$A
		end virtual
	end macro
	macro export_data? data, name, hname, hdef&
		virtual exports.area
			db 3
			dw data-flashexecbase
			db name, 0
		end virtual
		virtual header.area
			db hdef
			db $A
		end virtual
	end macro
	macro export_ptr? routine, name, hname, hdef&
		virtual exports.area
			db 8
			dl routine
			db name, 0
		end virtual
		virtual header.area
			db hdef
			db $A
		end virtual
		virtual symbols.area
			db "public _", hname,$A
			db '_',hname,' := syscall "',sclname,'/',name,'"',$A
		end virtual
	end macro
	macro ram_routine? routine, ramloc
		routine.ramroutine:
		routine.dataloc:
		virtual at ramloc
		macro end?.ram_routine?
			routine.len := $-$$
			load routine.data: $-$$ from $$
			end virtual
			dw routine.len
			dl ramloc
			db routine.data
			purge end?.ram_routine?
		end macro
	end macro
	macro data_block?
		local data
		virtual
		macro end?.data_block?
			data.len := $-$$
			load data.data: $-$$ from $$
			end virtual
			dw data.len
			db data.data
			purge end?.data_block?
		end macro
	end macro
	macro end?.syscalllib?
		load exports.code: $-$$ from $$
		end virtual
		virtual exports.area
			db 0
			load exports.data: $-$$ from $$
		end virtual
		db exports.data
		db exports.code
		purge call?
		purge jp?
		purge jq?
		purge ld?
		purge syscall?
		purge export?
		purge end?.syscalllib?
	end macro
	iterate opcode, call,jp,jq,ld,syscall
		macro opcode? args&
			match lhs=,rhs, args
				match (val), lhs
					if val relativeto flashexecbase
						rst $28
						opcode (0), rhs
						store val - $ : 3 at $ - 3
					else
						opcode (val), rhs
					end if
				else match (val), rhs
					if val relativeto flashexecbase
						rst $28
						opcode lhs, (0)
						store val - $ : 3 at $ - 3
					else
						opcode lhs, (val)
					end if
				else if rhs relativeto flashexecbase
					rst $28
					opcode lhs, 0
					store rhs - $ : 3 at $ - 3
				else
					opcode lhs, rhs
				end if
			else match opcode= lhs, line
				match (val), lhs
					opcode lhs
				else if lhs relativeto flashexecbase
					rst $28
					opcode 0
					store lhs - $ : 3 at $ - 3
				else
					opcode lhs
				end if
			else if args relativeto flashexecbase
				opcode args - flashexecbase
			else
				opcode args
			end if
		end macro
	end iterate
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
; Device macros
;-------------------------------------------------------------------------------

macro device_file? flags, type, version, intsource
	virtual
	db $C9, flags, type, version, intsource, 0, 0, 0
	repeat 11
		or a,a
		sbc hl,hl
		ret
	end repeat
	macro export? jumpno, function
		if function > 0
			store $C3: byte at $$+jumpno
			store function: 3 at $$+jumpno+1
		end if
	end macro
	macro end?.device_file?
		local data
		load data: $-$$ from $$
		end virtual
		db data
		purge export?
	end macro
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
?sc_HandleSysCall                := $20114
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
?drv_InitDevice                  := $22534
?fs_CopyFile                     := $22538
?sys_GetRandomAddress            := $2253C
?sys_Random8                     := $22540
?sys_Random32                    := $22544
?fs_GetSector                    := $22548
?fs_WriteByte                    := $2254C
?fs_RenameFile                   := $22550
?_SetCursorPos                   := $22554
?fs_CreateDir                    := $22558
?gfx_BufClear                    := $2255C
?gfx_LcdClear                    := $22560
?fs_SanityCheck                  := $22564
?sys_SetOnInterruptHandler       := $22568
?gui_PrintChar                   := $2256C
?gfx_SetDraw                     := $22570
?gui_PrintString                 := $22574
?gui_PrintLine                   := $22578
?gui_PrintUInt                   := $2257C
;DONOTHING                       := $22580
;DONOTHING                       := $22584
?fs_GetFilePtrRaw                := $22588
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
?fs_GetFDPtrRaw                  := $22630
?fs_GetFDLenRaw                  := $22634
?_OP1ToPath                      := $22638
?th_WaitKeyCycle                 := $2263C
?fs_JoinPath                     := $22640
?sys_MallocPersistent            := $22644
?sys_OpenFileInVar               := $22648
?fs_BaseName                     := $2264C
?fs_MoveFile                     := $22650
?fs_WriteDirectly                := $22654
?_UnpackUpdates                  := $22658
?sys_ReadSectorCache             := $2265C
?sys_WriteSectorCache            := $22660
?sys_OpenFileInLib               := $22664
?sys_LoadHookThreads             := $22668
?gfx_BlitScreen                  := $2266C
?th_CreateThread                 := $22670
?gfx_ZeroVRAM                    := $22674
?th_KillThread                   := $22678
?fs_GetFilePtr                   := $2267C
?fs_GetFDPtr                     := $22680
?fs_GetFDLen                     := $22684
?fs_ArcUnarcFD                   := $22688
?util_Zx0Decompress              := $2268C
?sys_WaitKeyUnpress              := $22690
?sys_MallocDupStr                := $22694
?sys_MallocDupStrN               := $22698
?_SearchSymTable                 := $2269C
?fs_Rename                       := $226A0
?fs_AllocChk                     := $226A4
?sys_GetExecType                 := $226A8
?sys_GetExecTypeFD               := $226AC
?util_Zx7Compress                := $226B0
?sys_OpenRecoveryMenu            := $226B4
?util_Relocate                   := $226B8
?fs_GetFDAttr                    := $226BC
?util_InitAllocSymList           := $226C0
?util_AppendSymList              := $226C4
?util_RemoveFromSymList          := $226C8
?util_SearchSymList              := $226CC
?util_FreeSymList                := $226D0
?sys_Exec                        := $226D4
?sys_ExecV                       := $226D8
?sys_ExecData                    := $226DC
?sys_ExecBegin                   := $226E0
?sys_ExecContinue                := $226E4
?fs_IsOSBackupPresent            := $226E8
?util_SHA256                     := $226EC
?str_FromByte                    := $226F0
?str_FromInt                     := $226F4
?str_FromLong                    := $226F8
?str_ToInt                       := $226FC
?gui_CharFromCode                := $22700
?sys_ExecuteFileArgcArgv         := $22704
?drv_OpenDevice                  := $22708
?drv_OpenDeviceFD                := $2270C
?drv_GetDMA                      := $22710
?drv_GetChar                     := $22714
?drv_PutChar                     := $22718
?drv_Read                        := $2271C
?drv_Write                       := $22720
?gui_PrintStdout                 := $22724
?sys_CallExecuteFileHere         := $22728
?fsd_Open                        := $2272C
?fsd_Close                       := $22730
?fsd_CloseAll                    := $22734
?fsd_Read                        := $22738
?fsd_Write                       := $2273C
?fsd_Resize                      := $22740
?fsd_WriteStr                    := $22744
?fsd_InRam                       := $22748
?fsd_IsOpen                      := $2274C
?fsd_Archive                     := $22750
?fsd_UnArchive                   := $22754
?fsd_Seek                        := $22758
?fsd_Tell                        := $2275C
?fsd_ForceClose                  := $22760
?fsd_GetSize                     := $22764
?fsd_GetDataPtr                  := $22768
?sys_AllocHeap                   := $2276C
?fs_ExtractRootDir               := $22770
?fs_ExtractOSBinaries            := $22774
?fs_ExtractOSOptBinaries         := $22778
;	
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
?lcd_text_fg            := ti.textFGColor      ; 1 byte
?lcd_text_bg            := ti.textFGColor+1    ; 1 byte
?lcd_text_fg2           := ti.textBGColor      ; 1 byte
?lcd_text_bg2           := ti.textBGColor+1    ; 1 byte
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
?copy_buffer            := ti.appData+33 ; 3 bytes, points to first copy buffer entry, or 0 if nothing is stored.
?threading_enabled      := ti.appData+36 ; 1 byte, determines if software threading is enabled and whether it should be used in OS routines
?current_thread         := ti.appData+37 ; 1 byte, currently running thread ID
?gfx_string_temp        := ti.appData+38 ; 16 bytes, temp location for integer printing
?offset_inst_hl_temp    := ti.appData+54 ; 3 bytes, used by handle_offsetinstruction
?offset_inst_sp_temp    := ti.appData+57 ; 3 bytes, used by handle_offsetinstruction
?saved_LcdUpbase        := ti.appData+60 ; 3 bytes, saves LcdUpbase during sector caching
?text_flags             := ti.appData+63 ; 1 byte. Instructs the OS character printing routines
?gfx_routine_temp       := ti.appData+64 ; 16 bytes, temp location for graphics routines
?LastExitCode           := ti.appData+80 ; 4 bytes, stores the exit code of the last program that finished executing
?stdout_device_ptr      := ti.appData+84 ; 3 bytes, stores pointer to stdout device structure
?random_source_ptr      := ti.appData+87 ; 3 bytes, stores pointer to random source address
?variable_sym_list_ptr  := ti.appData+90 ; 3 bytes, stores pointer to symbol list containing variables for command processing
?stdout_fd_ptr          := ti.appData+93 ; 3 bytes, stores pointer to stdout (or other) file descriptor
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
?bos_UserMem            := ti.userMem
?end_of_usermem         := $D3F000
?op_stack_bot           := $D0017C ; 256 bytes OP stack
?op_stack_top           := $D0027C ; 256 bytes downward
?current_working_dir    := $D00B00 ; 256 bytes current working directory
?InputBuffer            := $D00C00 ; 256 bytes input buffer
?open_device_table      := $D02380
?open_device_table.len  := $18
?open_file_table        := $D02398
?open_file_table.len    := $68
?open_file_table.max_open := 8
?thread_map             := $D02400 ; thread map. 64 threads. Active threads have bit 7 set.
?thread_parents         := $D02440 ; 64 bytes, one per thread. Saves ID of thread that spawned a given thread. A thread will only be run if it's parent thread is awake
?max_num_threads        := 64
?malloc_cache           := $D01200 ; $1100 (4352) bytes
?malloc_cache_len       := $100     ; (each cache entry byte marks 16 bytes of memory)
?bottom_of_malloc_ram   := malloc_cache+malloc_cache_len ; note: malloc memory needs to start 256 byte aligned
?bottom_of_malloc_RAM   := bottom_of_malloc_ram
?thread_temp_save       := $D00700 ; temporary save location for registers when a thread switch is triggered. 16 bytes per thread, 63 threads = 1008 bytes.
?top_of_malloc_ram      := top_of_ram
?malloc_block_size      := 16
?malloc_block_size_bits := 4
?top_of_ram             := $D40000
?top_of_RAM             := top_of_ram
?top_of_vat             := top_of_ram
?start_of_user_archive  := $040000 ;sector $04
?fs_root_dir_lba := $010000 shr fs_sector_size_bits
?fs_root_dir_address := start_of_user_archive + $010000
?end_of_user_archive    := $3B0000 ;sector $3B, start of certificate
?fs_cluster_map.len := (end_of_user_archive - start_of_user_archive)/fs_sector_size
?fs_cluster_map := $3C0000 - fs_cluster_map.len
?fs_cmap_length := fs_cluster_map.len
?fs_os_backup_location := $2E0000
?fs_sector_size                := 64
?fs_sector_size_bits           := 6
?fscluster_smallallocblocksize := 1024
?fs_partition_desc_size        := 16
?fs_file_desc_size             := 16
?fs_directory_size             := 256
?fscluster_freed             := $00
?fscluster_allocated         := $FE
?fscluster_clean             := $FF
?textflag_transparent_bg := 0	; set to draw text with a transparent background
?textflag_transparent_fg := 1	; set to draw text with a transparent foreground unless transparent background is set.
?fd_executable := 0
?fd_hidden     := 1
?fd_system     := 2
?fd_subfile    := 3
?fd_subdir     := 4
?fd_device     := 5
?fd_link       := 6
?fd_elevated   := 7
?fsentry_deleted            := $00
?fsentry_extendedsection    := $24
?fsentry_dot                := $2E
?fsentry_longfilename       := $F1
?fsentry_unlisted           := $F2
?fsentry_longfilename_entry := $F3
?fsentry_dirextender        := $FE
?fsentry_endofdir2          := $FF
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
?device_IntSource            := 4 ; what interrupt source this device responds to.
?device_FilesystemDeviceFlags:= 5 ; filesystem device flags if this device can be used as a filesystem.
?device_JumpTable            := 8 ; jump table for device functions.
?device_JumpInit             := 8
?device_JumpDeinit           := 12
?device_JumpRead             := 16
?device_JumpWrite            := 20
?device_JumpGetDMA           := 24
?device_JumpInt              := 28
?device_JumpOpenFile         := 32
?device_JumpCreateFile       := 36
?device_JumpDeleteFile       := 40
?device_JumpReadFile         := 44
?device_JumpWriteFile        := 48
?device_CodeStart            := 52
?device_Header.len           := 1
?device_Flags.len            := 1
?device_Type.len             := 1
?device_Version.len          := 1
?device_IntSource.len        := 1
?device_JumpTable.len        := 6*4 ; jump table for device functions
?bDeviceWritable             := 7
?bDeviceReadable             := 6
?bDeviceHasDMA               := 5
?bDeviceDMAWritable          := 4
?bDeviceDMAReadable          := 3
?bDeviceNeedsInit            := 2
?bDeviceNeedsDeinit          := 1
?mDeviceWritable             := 1 shl bDeviceWritable
?mDeviceReadable             := 1 shl bDeviceReadable
?mDeviceHasDMA               := 1 shl bDeviceHasDMA
?mDeviceDMAWritable          := 1 shl bDeviceDMAWritable
?mDeviceDMAReadable          := 1 shl bDeviceDMAReadable
?mDeviceNeedsInit            := 1 shl bDeviceNeedsInit
?mDeviceNeedsDeinit          := 1 shl bDeviceNeedsDeinit
?devtSoftware                := $00
?devtMemory                  := $04
?devtMMIO                    := $08
?devtIntHandler              := $09
?devtUSB                     := $10
?devtMSD                     := $14
?devtMTP                     := $15
?devtFS                      := $20
?deviceIntNone               := $00
?deviceIntOn                 := $01
?deviceIntTmr1               := $02
?deviceIntTmr2               := $03
?deviceIntTmr3               := $04
?deviceIntOSTmr              := $05
?deviceIntKey                := $0B
?deviceIntLcd                := $0C
?deviceIntRtc                := $0D
?deviceIntUsb                := $0E
?bDeviceFsReadable           := 0
?bDeviceFsWritable           := 1
?bDeviceFsWriteable          := 1
?mDeviceFsReadable           := 1 shl bDeviceFsReadable
?mDeviceFsWritable           := 1 shl bDeviceFsWritable
?mDeviceFsWriteable          := 1 shl bDeviceFsWritable
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
?bReturnData          := 4
?bReturnFromFullscreen:= 5
?mReturnNotError      := 1 shl bReturnNotError
?mReturnHex           := 1 shl bReturnHex
?mReturnLong          := 1 shl bReturnLong
?mSilentReturn        := 1 shl bSilentReturn
?mReturnData          := 1 shl bReturnData
?mReturnFromFullscreen:= 1 shl bReturnFromFullScreen
?bReturnFromFullScreen:=bReturnFromFullscreen
?mReturnFromFullScreen:=mReturnFromFullscreen
?symbol.next         := 0 ; 24-bit pointer to next symbol. 0 if end of list.
?symbol.name         := 3 ; 24-bit pointer to null terminated symbol name
?symlist.size        := 6 ; size of first symbol in symbol list
?symbol.flags        := 6 ; 8-bit symbol flag byte
?symbol.value        := 7 ; 24-bit symbol value
?symbol.entry_size   := 10
?symbol.end          := 0

end namespace