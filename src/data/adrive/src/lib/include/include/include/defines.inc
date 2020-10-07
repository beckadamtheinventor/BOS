
;-------------------------------------------------------------------------------
; LCD defines
;-------------------------------------------------------------------------------

LCD_PAL    := 0E30200h
LCD_CTRL   := 0E30018h
LCD_VRAM   := 0D40000h
LCD_BUFFER := LCD_VRAM + LCD_WIDTH*LCD_HEIGHT
LCD_WIDTH  := 320
LCD_HEIGHT := 240
LCD_8BPP   := $27
LCD_16BPP  := $2D

TEXT_MAX_ROW    := 231

;-------------------------------------------------------------------------------
; OS defines
;-------------------------------------------------------------------------------

RAM_START  := 0D00400h


; flag memory locations
flag_start             := $D00000

currow?                := console_line
curcol?                := console_col

lcd_bg_color           := $D00010
text_fg                := $D00011
text_bg                := $D00012
color_primary          := $D00013
font_spacing           := $D00014
font_data              := $D00017
lcd_x                  := $D0001A
lcd_y                  := $D0001D
free_RAM_ptr           := $D00020
remaining_free_RAM     := $D00023
free_VAT_entry_ptr     := $D00026
lcd_text_fg            := $D00027
lcd_text_bg            := $D00028
cursor_color           := $D00029
console_col            := $D0002A
op_stack_ptr           := $D0002B
free_file_RAM_ptr      := $D00030
remaining_file_RAM     := $D00033
console_line           := $D00036
bottom_of_RAM          := $D00037
ScrapMem2              := $D00079
ScrapByte              := $D0007C
ScrapWord              := $D0007D
ScrapMem               := $D0007D
open_files_table       := $D00100
InputBuffer            := $D00200
gfx_string_temp        := $D00300
current_working_dir    := $D00310
argument_stack_top     := $D00470 ;96 bytes downward
op_stack_top           := $D00670 ;512 bytes downward
prev_interrupt_status  := $D00670 ;2 bytes. Used to save interrupt flags when an interrupt is triggered.
os_handled_interrupts  := $D00672 ;2 bytes. Used to tell the OS whether to acknowledge certain interrupt bits. 1 = OS handled. 0 = User handled.
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
bos_Stackbot           := $D1A87C
bos_UserMem            := $D1A881
top_of_RAM             := $D40000


; Flash locations
start_of_user_archive  := $0C0000 ;sector $0C, standard
end_of_user_archive    := $3B0000 ;sector $3B, start of certificate


fd_readonly   := 1
fd_hidden     := 2
fd_system     := 4
fd_volume     := 8
fd_subdir     := $10
fd_archive    := $20
fd_device     := $40
