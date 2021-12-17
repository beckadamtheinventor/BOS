
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jq mem_edit
	db "REX",0
mem_edit:
	call libload_load
	ret nz
	ld hl,-14
	call ti._frameset
	xor a,a
	ld (ix-12),a
mem_edit_main:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jr nz,.dont_run_readme
	call mem_edit_readme
	cp a,15
	jq z,.exit
.dont_run_readme:
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.dont_open_file
	cp a,'$'
	jq z,.seek_to_offset
	push hl
	call bos.fs_GetFilePtr
	pop de
	jq c,.dont_open_file
	ld (ix-11),bc
	push bc,hl,bc
	ld hl,bos.safeRAM
	ld bc,65536
	push hl
	pop de
	inc de
	ld (hl),c
	ldir
	pop bc,hl
	inc bc
	ld de,bos.safeRAM
	push de
	ldir
	pop de,hl
	add hl,de
	ld (ix-14),hl
	ex hl,de
	jq .init_editor
.seek_to_offset:
	ex hl,de
	or a,a
	sbc hl,hl
.seek_to_offset_interpret_loop:
	ld a,(de)
	inc de
	or a,a
	jq z,.init_editor
	cp a,' '
	jq z,.init_editor
	push de
	call .interpret_nibble
	pop de
	jq .seek_to_offset_interpret_loop	
.interpret_nibble:
	cp a,'0'
	ret c
	cp a,'a'+1
	jq c,.interpret_upper
	cp a,'f'+1
	ret nc
	sub a,$27
	jq .interpret_nibble_lteq9
.interpret_upper:
	cp a,'F'+1
	ret nc
	cp a,'9'+1
	jq c,.interpret_nibble_lteq9
	sub a,7
.interpret_nibble_lteq9:
	sub a,'0'
	add hl,hl ;total*2
	add hl,hl ;total*4
	add hl,hl ;total*8
	add hl,hl ;total*16
	jq bos.sys_AddHLAndA ;total*16 + nibble
	
.dont_open_file:
	ld hl,$D00000
.init_editor:
	ld (ix-3),hl
	call gfx_ZeroScreen
	xor a,a
	sbc hl,hl
	ld (ix-6),hl
	ld (ix-7),a
	ld (ix-8),a
.main_loop:
	ld a,(ix-7)
	cp a,$FF
	jq nz,.main_draw
	and a,7
	ld (ix-7),a
	jq .backwardpage
.main_set_file_max:
	ld a,(ix-12)
	or a,a
	jq z,.main_draw
	ld a,1
	ld (edited_file),a
	ld bc,(ix-3)
	sbc hl,hl
	ld l,(ix-7)
	add hl,bc
	ld bc,bos.safeRAM
	sbc hl,bc
	jq c,.main_draw
	ld bc,(ix-11)
	sbc hl,bc
	jq c,.main_draw
	add hl,bc
	ld (ix-11),hl
	ld bc,bos.safeRAM
	add hl,bc
	ld (ix-14),hl
.main_draw:
	call .clearscreen
	call _setdefaultcolors
	ld bc,(ix-3)
	push bc
	or a,a
	sbc hl,hl
	ld l,(ix-7)
	add hl,bc ;add cursor offset
	ld a,(ix-12)
	or a,a
	jq z,.draw_address
	ld bc,bos.safeRAM
	sbc hl,bc
.draw_address:
	call _print24h
	pop hl
	ld a,3
	ld (currow),a
	xor a,a
	ld (curcol),a
	ld c,16
.outer:
;draw hex
	ld b,8
	push hl
.inner:
	ld a,(hl)
	inc hl
	push hl,bc
	call _print8h
	ld hl,curcol
	inc (hl)
	pop bc,hl
	djnz .inner
;draw characters
	pop de
	ld b,8
.inner2:
	ld a,(de)
	inc de
	cp a,$80
	push de,bc
	jq nc,.dont_print_c
	call _printc
	jq .printed_c
.dont_print_c:
	ld hl,curcol
	inc (hl)
.printed_c:
	pop bc,de
	djnz .inner2
;advance to next row
	ld hl,currow
	inc (hl)
	ex hl,de
	xor a,a
	ld (curcol),a
	dec c
	jq nz,.outer
;draw cursor
	or a,a
	sbc hl,hl
	ld a,(ix-7) ;cursor offset
	call .lcd_ptr_from_cursor
	ld bc,320*9
	add hl,bc
	ld bc,14
	ld (hl),$37
	push hl
	pop de
	inc de
	ldir
;draw end of file marker if we're editing a file and it's in view
	ld a,(ix-12)
	or a,a
	jq z,.done_drawing
	ld hl,(ix-14)
	ld de,(ix-3)
	or a,a
	sbc hl,de
	jq c,.done_drawing ;end of file before start of page
	ld de,8*16
	or a,a
	ld a,l
	sbc hl,de
	jq nc,.done_drawing ;end of file after end of page
	push af
	call .lcd_ptr_from_cursor
	ld de,-6
	add hl,de
	ld de,320
	ld b,8
.draw_eof_loop:
	ld (hl),$E0
	add hl,de
	djnz .draw_eof_loop
	pop af
	ld c,a
	rra
	rra
	rra
	and a,$F
	add a,3
	ld l,a
	ld h,9*20
	mlt hl    ;row*9*20
	add hl,hl ;row*9*40
	add hl,hl ;row*9*80
	add hl,hl ;row*9*160
	add hl,hl ;row*9*320
	ld de,$D52C00
	add hl,de
	ld a,c
	and a,7 ;column
	ld b,a
	ld c,27
	mlt bc ;column*27
	ld a,c
	or a,b
	jq nz,.draw_eof_lower
	ld bc,27*8 + 14
	jq .draw_eof_upper
.draw_eof_lower:
	push bc
	ld bc,320*8
	add hl,bc
	pop bc
.draw_eof_upper:
	ld (hl),$E0
	push hl
	pop de
	inc de
	ldir
.done_drawing:
	call gfx_BlitBuffer
.keys:
	call bos.sys_WaitKey
	ld c,(ix-7)
	cp a,5
	jq nc,.notarrowkey
	push af
	ld a,2
	call ti.DelayTenTimesAms
	pop af
	cp a,4
	jq z,.up
	cp a,3
	jq z,.right
	cp a,2
	jq z,.left
	cp a,1
	jq z,.down
.notarrowkey:
	push af
.waitkeyunpress:
	call bos.sys_AnyKey
	jq nz,.waitkeyunpress
	pop af
	cp a,9
	jq z,.input_string
	cp a,42 ;"->" / "x" key
	jq z,._write_file
	cp a,15 ;clear key
	jq z,.exit
	cp a,53 ;yequ key
	jq z,.setaddress
	cp a,10 ;"+" key
	jq z,.forwardfullpage
	cp a,11 ;"-" key
	jq z,.backwardfullpage
	call getnibble
	jq nz,.keys
	push bc
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	call getnibble
	pop de
	jq nz,.keys
	ld a,e
	rla
	rla
	rla
	rla
	add a,c
	ld hl,(ix-3)
	ld c,(ix-7)
	add hl,bc
	inc c
	ld (ix-7),c
	ld bc,$D00000
	or a,a
	sbc hl,bc
	add hl,bc
	jq c,.main_loop
	ld (hl),a
	jq .main_set_file_max
.exit:
	ld a,0
edited_file:=$-1
	or a,a
	call nz,.write_file
	call gfx_ZeroScreen
	call gfx_BlitBuffer
	ld sp,ix
	pop ix
	xor a,a
	sbc hl,hl
	ret
.up:
	ld a,c
	sub a,8
	jq nc,.loadcursor
.backwardpage:
	ld bc,-8
.advancepage:
	ld hl,(ix-3)
	add hl,bc
	ld (ix-3),hl
	jq .dontloadcursor
.backwardfullpage:
	ld bc,-8*16
	jq .advancepage
.forwardfullpage:
	ld bc,8*16
	jq .advancepage
.down:
	ld a,c
	add a,8
	cp a,8*16
	jq c,.loadcursor
.forwardpage:
	ld bc,8
	jq .advancepage
.left:
	ld a,c
	dec a
	jq nc,.loadcursor
	ld a,16*8-1
	ld (ix-7),a
	jq .forwardpage
.right:
	ld a,c
	inc a
	cp a,16*8
	jq c,.loadcursor
	ld a,15*8
	ld (ix-7),a
	jq .forwardpage
.loadcursor:
	ld (ix-7),a
.dontloadcursor:
	jq .main_loop
.setaddress:
	call .getaddress
	jq c,.main_loop
	ld hl,(ix-6)
	ld (ix-3),hl
	xor a,a
	jq .main_loop
.getaddress:
	call .clearscreen
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	lea hl,ix-4 ;upper byte of address
	call .getaddrbyte
	lea hl,ix-5 ;high byte of address
	call nc,.getaddrbyte
	lea hl,ix-6 ;low byte of address
	ret c
.getaddrbyte:
	push hl
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	call getnibble
	jq nz,.exitaddrloop
	ld (ix-8),c
	ld a,c
	call _print4h
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	call getnibble
	jq nz,.exitaddrloop
	ld a,c
	ld l,a
	push hl
	call _print4h
	ld a,(ix-8)
	rlca
	rlca
	rlca
	rlca
	pop hl
	add a,l
	pop hl
	ld (hl),a
	call gfx_BlitBuffer
	or a,a
	ret
.lcd_ptr_from_cursor:
	ld c,a
	rra
	rra
	rra
	and a,$F
	add a,3
	ld l,a
	ld h,9*20
	mlt hl    ;row*9*20
	add hl,hl ;row*9*40
	add hl,hl ;row*9*80
	add hl,hl ;row*9*160
	add hl,hl ;row*9*320
	ld a,c
	and a,$7
	ld d,a
	ld e,27
	mlt de    ;col*27
	add hl,de ;col*27 + row*9*320
	ld de,$D52C00
	add hl,de ;&vRamBuffer[col*27 + row*9*320 + 2]
	ret
._write_file:
	call .write_file
	jq .main_loop
.write_file:
	ld hl,(ix+6) ;args
	ld a,(hl)
	cp a,'$'
	ret z
	call gfx_ZeroScreen
	ld bc,1
	push bc,bc
	ld hl,str_WriteFileAreYouSure
	push hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	cp a,9
	ret nz
	ld hl,(ix+6) ;args
	push hl
	call bos.fs_OpenFile
	jq c,.write_new_file
	ex (sp),hl
	ld bc,(ix-11)
	push bc
	call bos.fs_SetSize
	pop bc,bc
	ret c
	jq .write_file_data
.write_new_file:
	ld hl,(ix-11)
	ex (sp),hl
	ld c,0
	push bc,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
	ret c
.write_file_data:
	ld bc,0
	push bc,hl
	ld c,1
	push bc
	ld bc,(ix-11)
	push bc
	ld bc,bos.safeRAM
	push bc
	call nc,bos.fs_Write
	pop bc,bc,bc,bc,bc
	ret
.exitaddrloop:
	pop bc
	call gfx_BlitBuffer
	scf
	ret
.clearscreen:
	call gfx_ZeroScreen
	xor a,a
	ld (currow),a
	ld (curcol),a
	ret
.input_string:
	ld hl,(ix-3)
	ld a,(ix-7)
	call bos.sys_AddHLAndA
	ld bc,$D00000
	or a,a
	sbc hl,bc
	add hl,bc
	jq c,.main_draw
	ld bc,256
	push bc
	call bos.sys_Malloc
	pop bc
	jq c,.main_draw
	push bc,hl
	xor a,a
	ld (bos.curcol),a
	inc a
	ld (bos.currow),a
	call bos.gui_Input
	pop hl,bc
	or a,a
	jq z,.main_draw
	ld a,(hl)
	or a,a
	jq z,.main_draw
	ex hl,de
	ld hl,(ix-3)
	ld a,(ix-7)
	call bos.sys_AddHLAndA
	push hl,de
	call ti._strlen
	ex (sp),hl
	pop bc,de
	push bc,hl
	ldir
	call bos.sys_Free
	pop bc,hl
	ld a,(ix-7)
	call bos.sys_AddHLAndA
	ld bc,8*16
	or a,a
	sbc hl,bc
	jq c,.string_input_set_cursor
	ld de,(ix-3)
.string_input_page_down:
	ex hl,de
	add hl,bc
	ex hl,de
	sbc hl,bc
	jq nc,.string_input_page_down
	ld (ix-3),de
.string_input_set_cursor:
	add hl,bc
	ld (ix-7),l
	jq .main_set_file_max
	db 33,34,26,18,35,27,19,36,28,20,47,39,31,46,38,30
nibblekeys:=$-1
getnibble:
	ld hl,nibblekeys
	ld bc,16
	cpdr
	ret
_setdefaultcolors:
	ld c,0
	push bc
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	pop bc
	ld c,$FF
	push bc
	call gfx_SetTextFGColor
	pop bc
	ld c,$07
	push bc
	call gfx_SetColor
	pop bc
	ret

_print8h:
	push af
	rlca
	rlca
	rlca
	rlca
	call _print4h
	pop af

_print4h:
	and a,$F
	ld hl,.hexc
	call bos.sys_AddHLAndA
	ld a,(hl)
	ld hl,temp_byte_str
	ld (hl),a
	jq _print
.hexc:
	db "0123456789ABCDEF"
temp_byte_str:
	db 0,0

_print24h:
	ex hl,de
	ld hl,bos.ScrapMem
	ld (hl),de
	inc hl
	inc hl
	ld b,3
.loop:
	ld a,(hl)
	push hl,bc
	call _print8h
	pop bc,hl
	dec hl
	djnz .loop
	ret
_printc:
	ld hl,temp_byte_str
	ld (hl),a
_print:
	ld (.str),hl
	ld a,0
currow:=$-1
	ld c,a
	add a,a
	add a,a
	add a,a
	add a,c
	or a,a
	sbc hl,hl
	ld l,a
	push hl
	ld hl,0
curcol:=$-3
	push hl
	add hl,hl
	add hl,hl
	add hl,hl
	pop de
	add hl,de
	push hl
	ld hl,0
.str:=$-3
	push hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	ld hl,curcol
	inc (hl)
	ret

mem_edit_readme:
	call _setdefaultcolors
	call gfx_ZeroScreen
	ld hl,readme_strings
.loop:
	push hl
	ld hl,(hl)
	ld a,(hl)
	or a,a
	jq z,.exit
	call _print
	xor a,a
	ld (curcol),a
	ld hl,currow
	inc (hl)
	pop hl
	inc hl
	inc hl
	inc hl
	jq .loop
.exit:
	pop bc
	call gfx_BlitBuffer
	jq bos.sys_WaitKeyCycle

str_WriteFileAreYouSure:
	db "Write buffer to file? Press enter to confirm.",0
readme_strings:
	dl ._1, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, ._10, ._11, ._12, ._13, $FF0000
._1: db "--MEMEDIT v1.2 by BeckATI--",0
._2: db "Arrow keys navigate the cursor.",0
._3: db "Clear quits. +/- scroll up/down.",0
._4: db "0-9,A-F write hex nibbles.",0
._5: db "  (two of these must be pressed",0
._6: db "in order to write a byte)",0
._7: db "This program will only edit RAM.",0
._8: db "Because editing flash directly is",0
._9: db "usually a bad idea.",0
._10: db "Pressing x will write to the opened file.",0
._11: db "usage: memedit $xxxxxx : start at address",0
._12: db "memedit [file path] : open a file",0
._13: db "Press any key to continue.",0

libload_load:
	ld hl,.libload_name
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
	ld   de,libload_relocations
	ld   bc,.notfound
	push   bc
	ld   bc,$aa55aa
	jp   (hl)
.libload_name:
	db "/lib/LibLoad.dll",0

.notfound:
	xor   a,a
	inc   a
	ret

libload_relocations:
db	$C0, "GRAPHX", $00, 11
gfx_Begin:
	jq 0
gfx_SetColor:
	jq 6
gfx_SetDraw:
	jq 27
gfx_Blit:
	jq 33
gfx_PrintStringXY:
	jq 54
gfx_SetTextBGColor:
	jq 60
gfx_SetTextFGColor:
	jq 63
gfx_SetTextTransparentColor:
	jq 66
gfx_HorizLine:
	jq 93
gfx_ZeroScreen:
	jq 228

	xor a,a
	pop hl
	ret

gfx_BlitBuffer:
	ld c,1
	push bc
	call gfx_Blit
	pop bc
	ret

