
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jr main_init
	db "REX",0
main_init:
	xor a,a
	ld (bos.text_bg),a
	dec a
	ld (bos.text_fg),a
main_edit_open:
	pop bc,hl
	push hl,bc
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,failed_to_open
	ld bc,$C
	add hl,bc
	ld de,(hl)
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ex.s hl,de
	ld de,bos.safeRAM
	ldir
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
	xor a,a
	ld (bos.currow),a
	ld (bos.curcol),a
	ld hl,header_string
	call bos.gui_DrawConsoleWindow
	pop hl
	call bos.gui_Print
.loop:
	ld de,(end_of_file)
	or a,a
	sbc hl,de
	jq nc,gfx_BlitBuffer
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

str_FailedToOpen:
	db "Failed to open file.",$A,0

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

