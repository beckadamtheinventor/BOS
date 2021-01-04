
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

margin_top := 20
margin_bottom := 230
margin_left := 10
margin_right := 310

org ti.userMem
	jr main_init
	db "REX",0
main_init:
	pop bc,hl
	push hl,bc
	ld (open_file_name),hl
	call load_libload
	jq z,main_init_2
	ld hl,str_FailedToLoadLibload
	call bos.gui_Print
	scf
	sbc hl,hl
	ret
main_init_2:
	ld c,0
	push bc
	call gfx_SetTextBGColor
	call gfx_SetTextTransparentColor
	ld l,$FF
	ex (sp),hl
	call gfx_SetTextFGColor
	pop bc
main_edit_open:
	ld hl,0
open_file_name:=$-3
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,failed_to_open
	ld bc,0
	push bc,hl,hl
	pop iy
	ld hl,(iy+$E)
	ex.s hl,de
	ld c,1
	push bc,de
	ld hl,$D40000
	scf
	sbc hl,de
	push hl
	ld (edit_pointer),hl
	call bos.fs_Read
	pop bc,bc,bc,bc,bc
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	call main_edit_loop
	xor a,a
	sbc hl,hl
	ret

main_edit_loop:
	ld hl,0
edit_pointer:=$-3
	ld de,0
edit_page_offset:=$-3
	add hl,de
	call main_draw
	call bos.sys_WaitKey
	cp a,3
	jq z,cursor_right
	cp a,2
	jq z,cursor_left
	cp a,1
	jq z,cursor_down
	cp a,4
	jq z,cursor_up
	push af
.wait_key_loop:
	call bos.sys_AnyKey
	or a,a
	jq nz,.wait_key_loop
	pop af
	cp a,15
	ret z
	jq main_edit_loop
	
	
	ret

cursor_right:
	ld hl,(edit_pointer)
	ld de,(edit_page_offset)
	ld bc,(end_of_file)
	add hl,de
	ld de,(cursor_x)
	add hl,de
	ld a,(hl)
	or a,a
	sbc hl,bc
	jq nc,main_edit_loop
	cp a,$A
	jq nz,.inc
	
.inc:
	inc de
cursor_x_loadde:
	ld (cursor_x),de
	jq main_edit_loop

cursor_left:
	ld hl,(edit_pointer)
	ld de,(edit_page_offset)
	add hl,de
	ld de,(cursor_x)
	dec de
	add hl,de
	ld a,(hl)
	cp a,$A
	jq z,cursor_up
	
	jq cursor_x_loadde

cursor_up:
	ld hl,(cursor_y)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,page_up
	ld hl,(edit_pointer)
	ld de,(edit_page_offset)
	add hl,de
	
	
	ld (cursor_y),de
	jq main_edit_loop

page_up:
	ld hl,(edit_page_offset)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,main_edit_loop
	push hl
	pop bc
	ld hl,(edit_pointer)
	add hl,bc
	ld a,$A
	cpdr
	jq main_edit_loop


main_draw:
	push hl
	ld bc,margin_top
	push bc
	ld bc,margin_left
	push bc
	call gfx_SetTextXY
	pop bc,bc
	pop hl
	call .loop
	jq gfx_BlitBuffer
.loop:
	ld de,(end_of_file)
	or a,a
	sbc hl,de
	ret nc
	add hl,de
	ld a,(hl)
	cp a,$A
	jq z,.next_line
	ld c,a
	push hl,bc
	call gfx_GetTextX
	ld bc,310
	or a,a
	sbc hl,bc
	jq nc,.next_line
	call gfx_PrintChar
	pop bc,hl
	jq .loop
.next_line:
	push hl
	call gfx_GetTextY
	ld bc,line_height
	add hl,bc
	push bc,hl
	call gfx_SetTextXY
	pop bc,bc
	ld hl,margin_bottom
	pop hl
	jq .loop


failed_to_open:
	ld hl,str_FailedToOpen
print_and_fail:
	call bos.gui_Print
	scf
	sbc hl,hl
	ret


load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.notfound
	ld bc,$0C
	add hl,bc
	ld hl,(hl)
	push hl
	call bos.fs_GetSectorAddress
	pop bc
	ld   de,.relocations
	ld   bc,.notfound
	push   bc
;	ld   bc,$aa55aa
	jp   (hl)

.notfound:
	xor   a,a
	inc   a
	ret

.relocations:
	db	$C0, "GRAPHX", $00, 11
gfx_SetColor:
	jp 6
gfx_SetDraw:
	jp 27
gfx_Blit:
	jp 33
gfx_PrintChar:
	jp 42
gfx_PrintInt:
	jp 45
gfx_PrintString:
	jp 51
gfx_PrintStringXY:
	jp 54
gfx_SetTextXY:
	jp 57
gfx_SetTextBGColor:
	jp 60
gfx_SetTextFGColor:
	jp 63
gfx_SetTextTransparentColor:
	jp 66
gfx_GetTextX:
	jp 84
gfx_GetTextY:
	jp 87
gfx_ZeroScreen:
	jp 228

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

libload_name:
	db   "/lib/LibLoad.LLL", 0
.len := $ - .

gfx_BlitBuffer:
	ld c,1
	push bc
	call gfx_Blit
	pop bc
	ret

str_FailedToOpen:
	db "Failed to open file.",$A,0
str_FailedToLoadLibload:
	db "Failed to load libload.",$A,0

__keymaps:
	dl .keymap_A,.keymap_a,.keymap_1,0
.keymap_A:
	db '"',"WRMH  ?!VQLG  :ZUPKFC  YTOJEB  XSNIDA"
.keymap_a:
	db '"',"wrmh  ?!vqlg  :zupkfc  ytojeb  xsnida"
.keymap_1:
	db "+-*/^  ;369)$@ .258(&~ 0147,][  '<=>}{"
__overtypes:
	db "Aa1"

