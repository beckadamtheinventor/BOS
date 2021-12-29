
;-------------------------------------------------------------------------------
; LCD defines
;-------------------------------------------------------------------------------

LCD_PAL?    := 0E30200h
LCD_CTRL?   := 0E30018h
LCD_VRAM?   := 0D40000h
LCD_BUFFER? := LCD_VRAM + LCD_WIDTH*LCD_HEIGHT
LCD_WIDTH?  := 320
LCD_HEIGHT? := 240
LCD_8BPP?   := $27
LCD_16BPP?  := $2D

TEXT_MAX_ROW    := 231

;-------------------------------------------------------------------------------
; OS defines
;-------------------------------------------------------------------------------

RAM_START  := 0D00000h


; memory locations
flag_start             := $D00000

currow?                := ti.curRow
curcol?                := ti.curCol
console_col            := curcol
console_line           := currow

color_primary          := ti.drawFGColor      ; 1 byte
lcd_bg_color           := ti.drawFGColor+1    ; 1 byte
lcd_text_fg            := ti.textFGcolor      ; 1 byte
lcd_text_bg            := ti.textFGcolor+1    ; 1 byte
lcd_text_fg2           := ti.textBGcolor      ; 1 byte
lcd_text_bg2           := ti.textBGcolor+1    ; 1 byte
cursor_color           := ti.statusBarBGColor ; 1 byte
font_data              := ti.lFont_record
font_spacing           := ti.lFont_record+3
lcd_x                  := ti.lFont_record+6
lcd_y                  := ti.lFont_record+9
remaining_free_RAM     := ti.appData    ; 3 bytes
op_stack_ptr           := ti.appData+3  ; 3 bytes
on_interrupt_jump      := ti.appData+6  ; jump byte for on_interrupt_handler
on_interrupt_handler   := ti.appData+7  ; 3 bytes. Jump to on key interrupt handler. Byte preceeding this should be $C3 or $C9
cur_lcd_buffer         := ti.appData+10 ; 3 bytes. Points to current LCD buffer
running_process_id     := ti.appData+13 ; 1 byte. Current process ID (used for per-program memory allocation)
ScrapMem2              := ti.appData+14 ; 3 bytes
top_of_UserMem         := ti.appData+17 ; 3 bytes
LastCommandResult      := ti.appData+20 ; 4 bytes. Stores result of previously executed command
ExecutingFileFd        := ti.appData+24 ; 3 bytes. Pointer to currently executing file descriptor. -1 if file not found. 0 if file descriptor is not applicable
running_program_ptr    := ti.appData+27 ; 3 bytes. Stores pointer to currently running program
return_code_flags      := ti.appData+30 ; flag byte that determines how to interpret the return value of the last run program. Is to be set within the program for non-default return interpretation.
flashStatusByte        := ti.appData+31 ; 1 byte
filesystem_driver      := ti.appData+32 ; 1 byte
copy_buffer            := ti.appData+33 ;3 bytes, points to first copy buffer entry, or -1 if nothing is stored.
threading_enabled      := ti.appData+36 ;1 byte, determines if software threading is enabled and whether it should be used in OS routines
current_thread         := ti.appData+37 ;1 byte, currently running thread ID
gfx_string_temp        := ti.appData+38 ;16 bytes, temp location for integer printing
ScrapByte              := ti.flashByte
ScrapWord              := ti.scrapMem
ScrapMem               := ti.scrapMem
last_keypress          := ti.kbdScanCode ; 1 byte. Last keypress returned by an os getkey routine
asm_prgm_size          := ti.asm_prgm_size ;3 bytes
SaveSP                 := ti.errSP ; 3 bytes, saves SP when running programs.
fsOP1                  := ti.OP1
fsOP2                  := ti.OP2
fsOP3                  := ti.OP3
fsOP4                  := ti.OP4
fsOP5                  := ti.OP5
fsOP6                  := ti.OP6

safeRAM                := ti.pixelShadow ; 69090 bytes scrap RAM
safeRAM_len            := 69090
usbArea                := ti.usbArea ; 14306 bytes used for usb, probably need to disable timer3/usb interrupts to use
usbHandleKeys          := ti.usbHandleKeys ; zero this byte while using usbArea to keep GetCSC from affecting other parts of usbArea
usbInited              := ti.usbInited ; zero this byte while using usbArea and to reset the usb stack when interrupts are re-enabled
heapBot                := ti.heapBot
ramCodeTop             := ti.ramCodeTop
reservedRAM            := ti.ramCodeTop
bos_UserMem            := $D1A881
end_of_usermem         := libload_bottom_ptr-2
libload_bottom_ptr     := libload_top_ptr-$3FE ; 1022 bytes for executing libload
libload_top_ptr        := thread_temp_save-$400
op_stack_bot           := thread_temp_save-$400
op_stack_top           := thread_temp_save-$300 ;256 bytes downward
current_working_dir    := thread_temp_save-$200
InputBuffer            := thread_temp_save-$100
thread_temp_save       := $D2F000 ; temporary save location for registers when a thread switch is triggered. 16 bytes per thread, 256 threads = 4096 bytes.
malloc_cache           := $D2F800 ; 4096 bytes
thread_map             := $D30000 ; thread map. 256 threads. Active threads have bit 7 set.
thread_parents         := $D30100 ; 256 bytes, one per thread. Saves ID of thread that spawned a given thread. A thread will only be run if it's parent thread is awake
bottom_of_malloc_RAM   := $D30200
top_of_vat             := top_of_RAM
top_of_RAM             := $D40000


; Flash locations
start_of_user_archive  := $040000 ;sector $04
fs_root_dir_lba := $010000 shr 9
fs_root_dir_address := start_of_user_archive + $010000
end_of_user_archive    := $3B0000 ;sector $3B, start of certificate
fs_cluster_map := $3BE000
fs_cluster_map.len := 7040
fs_cmap_length := fs_cluster_map.len
; asset_locations_start  := $3C0000





; file entry flags
fd_readonly   := 0
fd_hidden     := 1
fd_system     := 2
fd_subfile    := 3
fd_subdir     := 4
fd_device     := 5
fd_link       := 6
fd_elevated   := 7

; file entry first byte
fsentry_endofdir        := $00
fsentry_dot             := $2E
fsentry_deleted         := $F0
fsentry_longfilename    := $F1
fsentry_unlisted        := $F2
fsentry_endofdir2       := $FF

; file entry offsets
fsentry_filename            := $00
fsentry_filename.len        := 8
fsentry_fileext             := $08
fsentry_fileext.len         := 3
fsentry_fileattr            := $0B
fsentry_fileattr.len        := 1
fsentry_filesector          := $0C
fsentry_filesector.len      := 2
fsentry_filelen             := $0E
fsentry_filelen.len         := 2

; device file field offsets
device_Header               := 0
device_Flags                := 1
device_Type                 := 2
device_Version              := 3
device_JumpTable            := 4 ; jump table for device functions
device_JumpInit             := 4
device_JumpDeinit           := 8
device_JumpRead             := 12
device_JumpWrite            := 16
device_JumpGetDMA           := 20
device_CodeStart            := 24

; device file field lengths
device_Header.len           := 4
device_Flags.len            := 1
device_Type.len             := 1
device_Version.len          := 1
device_JumpTable.len        := 5*4 ; jump table for device functions

; device file flag bits
bDeviceWritable             := 7
bDeviceReadable             := 6
bDeviceHasDMA               := 5
bDeviceDMAWritable          := 4
bDeviceDMAReadable          := 3
bDeviceNeedsInit            := 2
bDeviceNeedsDeinit          := 1

; device type equates
devtSoftware                := $00
devtMemory                  := $04
devtMMIO                    := $08
devtUSB                     := $10
devtMSD                     := $14
devtMSDFS                   := $15
devtMSDFAT32                := $16


; threading_enabled values
threadsDisabled             := 0
threadsEnabled              := 1
threadOSRoutines            := 2

; thread_map flags
bThreadAlive                := 7
bThreadPersistent           := 6
bThreadSleeping             := 5

; flashStatusByte flags
bIsFlashUnlocked     := 0
bKeepFlashUnlocked   := 1

mIsFlashUnlocked     := 1
mKeepFlashUnlocked   := 2

; return_code_flags flags
bReturnNotError      := 0
bReturnHex           := 1
bReturnLong          := 2
bSilentReturn        := 3
