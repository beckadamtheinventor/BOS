
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

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
main_edit_loop:
	ld hl,0
edit_pointer:=$-3
	ld de,0
edit_page_offset:=$-3
	add hl,de
	call main_draw
	
	ret

main_draw:
	push hl
	ld bc,9
	push bc,bc
	call gfx_SetTextXY
	pop bc,bc
	pop hl
.loop:
	ld a,(hl)
	cp a,$A
	jq z,.next_line
	or a,a
	ret z
	push hl,bc
	call gfx_GetTextX
	ld bc,310
	or a,a
	sbc hl,bc
	jq nc,.exit
	call gfx_PrintChar
	pop bc,hl
	jq .loop
.next_line:
	push hl
	call gfx_GetTextY
	ld bc,9
	add hl,bc
	push bc,hl
	call gfx_SetTextXY
	pop bc,bc
	pop hl
	jq .loop
.exit:
	pop bc,bc
	ret

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

