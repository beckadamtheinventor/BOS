
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

RAM_START  := 0D00400h


; flag memory locations
flag_start             := $D00000

currow?                := console_line
curcol?                := console_col

lcd_bg_color           := $D00210
lcd_text_fg            := $D00211
lcd_text_bg            := $D00212
color_primary          := $D00213
font_spacing           := $D00214
font_data              := $D00217
lcd_x                  := $D0021A
lcd_y                  := $D0021D
free_RAM_ptr           := $D00220
remaining_free_RAM     := $D00223
cursor_color           := $D00226
console_col            := $D00227
op_stack_ptr           := $D00228
console_line           := $D0022C
bottom_of_RAM          := $D0022D
flashStatusByte        := $D00230
filesystem_driver      := $D00231
on_interrupt_handler   := $D00235 ;3 bytes. Jump to on key interrupt handler. Byte preceeding this must be $C3 or $C9
cur_lcd_buffer         := $D00238 ;3 bytes. Points to current LCD buffer
running_process_id     := $D0023B ;1 byte. Current process ID (used for per-program memory allocation)
lcd_text_fg2           := $D0023C
lcd_text_bg2           := $D0023D
running_program_ptr    := $D0023E ;3 bytes. Stores pointer to currently running program
ScrapMem2              := $D00279
ScrapByte              := $D0027C
ScrapWord              := $D0027D
ScrapMem               := $D0027D
ExecutingFileFd        := $D00280 ; 3 bytes. Pointer to currently executing file descriptor. -1 if file not found. 0 if file descriptor is not applicable
LastCommandResult      := $D00283 ; 3 bytes. Points to result of previously executed command
last_keypress          := $D00286 ; 1 byte. Last keypress returned by an os getkey routine
open_files_table       := $D00300
InputBuffer            := $D00400
gfx_string_temp        := $D00500
current_working_dir    := $D00510
argument_stack_top     := $D00670 ;96 bytes downward
op_stack_top           := $D00870 ;512 bytes downward
gui_cursor_x           := $D00870
gui_cursor_y           := $D00873
fsOP1                  := $D01000
fsOP2                  := $D01010
fsOP3                  := $D01020
fsOP4                  := $D01030
fsOP5                  := $D01040
fsOP6                  := $D01050
current_cluster_map    := $D01080 ;3 bytes
argument_stack_current := $D01083 ;3 bytes
asm_prgm_size          := $D01086 ;3 bytes
top_of_UserMem         := $D01089 ;3 bytes
SaveSP                 := $D01092 ;3 bytes, saves SP when running programs.
current_thread         := $D01095 ; currently running thread ID
;asset_reservations_table:= $D01600 ;1024 bytes. Caches asset memory reservations
usb_sector_buffer      := $D01100 ;512 bytes
usbRAM                 := $D01300 ;256 bytes, should not be tampered with while /dev/mnt or /dev/usb are active
thread_map             := $D01400 ; thread map. 256 threads. Active threads have bit 7 set.
malloc_cache           := $D01500 ;4096 bytes
thread_temp_save       := $D02500 ; temporary save location for registers when a thread switch is triggered. 16 bytes per thread, 256 threads = 4096 bytes.
safeRAM                := $D03500 ; 68312 bytes scrap RAM
safeRAM_len            := 68312
usbArea                := $D13FD8 ; 14306 bytes used for usb, probably need to disable timer3/usb interrupts to use
usbHandleKeys          := $D14091 ; zero this byte while using usbArea to keep GetCSC from affecting other parts of usbArea
usbInited              := $D177B7 ; zero this byte while using usbArea and to reset the usb stack when interrupts are re-enabled
reservedRAM            := $D177BA
bos_UserMem            := $D1A881
bottom_of_malloc_RAM   := $D30000
top_of_RAM             := $D40000


; Flash locations
start_of_user_archive  := $040000 ;sector $04
end_of_user_archive    := $3B0000 ;sector $3B, start of certificate


asset_locations_start      := $3C0000

; file entry flags
fd_readonly   := 0
fd_hidden     := 1
fd_system     := 2
fd_subfile    := 3
fd_subdir     := 4
fd_device     := 5
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


; flashStatusByte flags
bIsFlashUnlocked     := 0
bKeepFlashUnlocked   := 1

mIsFlashUnlocked     := 1
mKeepFlashUnlocked   := 2

fs_cmap_length := 7040
