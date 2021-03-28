
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
text_fg                := $D00211
text_bg                := $D00212
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
ScrapMem2              := $D00279
ScrapByte              := $D0027C
ScrapWord              := $D0027D
ScrapMem               := $D0027D
ExecutingFileFd        := $D00280 ; 3 bytes. Pointer to currently executing file descriptor. -1 if file not found. 0 if file descriptor is not applicable
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
current_sectors_per_cluster := $D01095 ;1 byte. Number of sectors per cluster in last drive where fs_DataSection or fs_RootDir has been called on it.
usb_sector_buffer      := $D02000 ;512 bytes
malloc_cache           := $D03000 ;4096 bytes
usbRAM                 := $D05080 ;256 bytes, should not be tampered with while /dev/mnt or /dev/usb are active
safeRAM                := $D05200 ; 65536 bytes scrap RAM
safeRAM_len            := 65536
reservedRAM            := $D15200 ; 2048 bytes reserved RAM
reservedRAM_len        := 2048
bos_Stackbot           := $D1A87C
bos_UserMem            := $D1A881
driverExecRAM          := $D2F000 ; 4096 bytes RAM reserved for driver code
driverExecRAM_len      := 4096
bottom_of_malloc_RAM   := $D30000
top_of_RAM             := $D40000

; threading defines
thread_map             := $D02800 ; thread map. 256 threads. Active threads have bit 7 set.
thread_temp_save       := $D03000 ; temporary save location for registers when a thread switch interrupt is triggered. 32 bytes per thread, 256 threads = 8192 bytes.
current_thread         := $D05000 ; currently running thread ID
thread_control         := $D05001 ; zero if threading is disabled
thread_memory_end      := $D05002 ; end of thread memory

; Flash locations
start_of_user_archive  := $040000 ;sector $04
end_of_user_archive    := $3B0000 ;sector $3B, start of certificate


; file entry flags
fd_readonly   := 0
fd_hidden     := 1
fd_system     := 2
fd_volume     := 3
fd_subdir     := 4
fd_archive    := 5
fd_device     := 6

; flashStatusByte flags
bIsFlashUnlocked     := 0
bKeepFlashUnlocked   := 1

mIsFlashUnlocked     := 1
mKeepFlashUnlocked   := 2


