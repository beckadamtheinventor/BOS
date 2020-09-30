
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

; iy flags
iyflags                      := $D00080
flags.sys_flags              := -1
flags.lcd_bg_color           :=  0
flags.text_fg                :=  1
flags.text_bg                :=  2
flags.color_primary          :=  3
flags.font_spacing           :=  4
flags.font_data              :=  7
flags.lcd_x                  :=  10
flags.lcd_y                  :=  13
flags.free_RAM_ptr           :=  16
flags.remaining_free_RAM     :=  19
flags.free_VAT_entry_ptr     :=  22
flags.cursor_x               :=  25
flags.cursor_y               :=  28
flags.cursor_flags           :=  29
flags.lcd_text_fg            :=  30
flags.lcd_text_bg            :=  31
flags.cursor_color           :=  32
flags.free_file_RAM_ptr      :=  33
flags.remaining_file_RAM     :=  36
flags.console_line           :=  39
flags.bottom_of_RAM          :=  40

; bos_sys_flags flag bits
bos_read_only_fs        := 1

; cursor_flags flag bits
cursor_2nd              := 1


; iy flag memory locations
flag_start             := $D00000
lcd_bg_color           := $D00080
text_fg                := $D00081
text_bg                := $D00082
color_primary          := $D00083
font_spacing           := $D00084
font_data              := $D00087
lcd_x                  := $D0008A
lcd_y                  := $D0008D
free_RAM_ptr           := $D00090
remaining_free_RAM     := $D00093
free_VAT_entry_ptr     := $D00096
lcd_text_fg            := $D00097
lcd_text_bg            := $D00098
cursor_color           := $D00099
free_file_RAM_ptr      := $D000A0
remaining_file_RAM     := $D000A3
console_line           := $D000A6
bottom_of_RAM          := $D000A7
ScrapMem2              := $D000F9
ScrapByte              := $D000FC
ScrapWord              := $D000FD
ScrapMem               := $D000FD

; other RAM locations
open_files_table       := $D00100
InputBuffer            := $D00200
gfx_string_temp        := $D00300
current_working_dir    := $D00310
argument_stack_top     := $D00600
fsOP1                  := $D00600
fsOP2                  := $D00610
fsOP3                  := $D00620
fsOP4                  := $D00630
fsOP5                  := $D00640
fsOP6                  := $D00650
current_cluster_map    := $D00680 ;3 bytes long
usb_sector_buffer_ptr  := $D00683 ;3 bytes long
argument_stack_current := $D00686 ;3 bytes long
bos_Stackbot           := $D1A87C
bos_UserMem            := $D1A881
top_of_RAM             := $D40000


; Flash locations
start_of_user_archive  := $0C0000 ;sector $0C, standard
end_of_user_archive    := $3B0000 ;sector $3B, start of certificate



