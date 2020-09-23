
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
flags                   := $D00080
namespace flags
sys_flags              := -1
lcd_bg_color           :=  0
text_fg                :=  1
text_bg                :=  2
color_primary          :=  3
font_spacing           :=  4
font_data              :=  7
lcd_x                  :=  10
lcd_y                  :=  13
free_RAM_ptr           :=  16
remaining_free_RAM     :=  19
free_VAT_entry_ptr     :=  22
cursor_x               :=  25
cursor_y               :=  28
cursor_flags           :=  29
lcd_text_fg            :=  30
lcd_text_bg            :=  31
cursor_color           :=  32
free_file_RAM_ptr      :=  33
remaining_file_RAM     :=  36
console_line           :=  39
end namespace

; bos_sys_flags flag bits
bos_read_only_fs        := 1

; cursor_flags flag bits
cursor_2nd              := 1


; iy flag memory locations
flag_start             := $D00000
sys_flags              := $D0007F
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
ScrapMem2              := $D000F9
ScrapByte              := $D000FC
ScrapWord              := $D000FD
ScrapMem               := $D000FD

; other RAM locations
open_files_table       := $D00100
InputBuffer            := $D00200
gfx_string_temp        := $D00300
current_working_dir    := $D00310
stackbot               := $D08000
start_of_file_RAM      := $D10000
end_of_file_RAM        := $D40000
total_file_RAM         := end_of_file_RAM-start_of_file_RAM

; Flash locations
start_of_user_archive  := $0C0000 ;sector $0C, standard
end_of_user_archive    := $3B0000 ;sector $3B, start of certificate



