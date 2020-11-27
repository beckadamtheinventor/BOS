
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jr mem_edit
	db "REX",0
mem_edit:
	ld hl,-8
	call ti._frameset
	call libload_load
	ret nz
mem_edit_main:
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
	call mem_edit_readme
	cp a,15
	jq z,.exit_nocls
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.dont_open_file
	cp a,'$'
	jq z,.seek_to_offset
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.dont_open_file
	ld bc,$E
	push hl
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	ld bc,(bos.remaining_free_RAM)
	or a,a
	sbc hl,bc
	add hl,bc
	ex hl,de
	pop hl
	jq nc,.file_too_large
	ld bc,0
	push bc ;int offset
	push hl ;void *fd
	ld c,1
	push bc ;uint8_t count
	push de ;int len
	ld bc,(bos.top_of_UserMem)
	push bc ;void *dest
	call bos.fs_Read
	pop hl,bc,bc,bc,bc
	jq .init_editor
.file_too_large:
	ld hl,string_file_too_large
	call _print
	jq .dont_open_file
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
	jr nz,.main_draw
	and a,7
	ld (ix-7),a
	jq .backwardpage
.main_draw:
	call .clearscreen
	call _setdefaultcolors
	ld bc,(ix-3)
	push bc
	or a,a
	sbc hl,hl
	ld l,(ix-7)
	add hl,bc ;add cursor offset
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
	jr nc,.dont_print_c
	call _printc
	jr .printed_c
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
	jr nz,.outer
	or a,a
	sbc hl,hl
	ld a,(ix-7) ;cursor offset
	ld c,a
	rra
	rra
	rra
	and a,$F
	inc a
	inc a
	inc a
	ld l,a
	ld h,9
	mlt hl
	ld a,c
	and a,$7
	ld d,a
	ld e,27
	mlt de
	ld bc,8
	add hl,bc
	ld c,18
	push bc,hl,de
	call gfx_HorizLine
	pop bc,bc,bc
	call gfx_BlitBuffer
.keys:
	call bos.sys_WaitKey
	ld c,(ix-7)
	cp a,5
	jr nc,.notarrowkey
	push af
	call ti.Delay10ms
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
	jr nz,.waitkeyunpress
	pop af
	cp a,15 ;clear key
	jq z,.exit
	cp a,53 ;yequ key
	jq z,.setaddress
	cp a,10 ;"+" key
	jq z,.forwardfullpage
	cp a,11 ;"-" key
	jq z,.backwardfullpage
	ld bc,16
	ld hl,.nibblekeys+15
	cpdr
	jr nz,.keys
	push bc
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	ld bc,16
	ld hl,.nibblekeys+15
	cpdr
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
	jp .main_loop
.exit:
	call gfx_ZeroScreen
	call gfx_BlitBuffer
.exit_nocls:
	ld sp,ix
	pop ix
	xor a,a
	sbc hl,hl
	ret
.up:
	ld a,c
	sub a,8
	jr nc,.loadcursor
.backwardpage:
	ld bc,-8
.advancepage:
	ld hl,(ix-3)
	add hl,bc
	ld (ix-3),hl
	jr .dontloadcursor
.backwardfullpage:
	ld bc,-8*16
	jr .advancepage
.forwardfullpage:
	ld bc,8*16
	jr .advancepage
.down:
	ld a,c
	add a,8
	cp a,8*16
	jr c,.loadcursor
.forwardpage:
	ld bc,8
	jr .advancepage
.left:
	ld a,c
	dec a
	jr nc,.loadcursor
	ld a,16*8-1
	ld (ix-7),a
	jr .forwardpage
.right:
	ld a,c
	inc a
	cp a,16*8
	jr c,.loadcursor
	ld a,15*8
	ld (ix-7),a
	jr .forwardpage
.loadcursor:
	ld (ix-7),a
.dontloadcursor:
	jp .main_loop
.setaddress:
	call .getaddress
	jp c,.main_loop
	ld hl,(ix-6)
	ld (ix-3),hl
	xor a,a
	jp .main_loop
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
	ld bc,16
	ld hl,.nibblekeys+15
	cpdr
	jr nz,.exitaddrloop
	ld (ix-8),c
	ld a,c
	call _print4h
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	ld bc,16
	ld hl,.nibblekeys+15
	cpdr
	jr nz,.exitaddrloop
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
.nibblekeys:
	db 33,34,26,18,35,27,19,36,28,20,47,39,31,46,38,30
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


___WriteFlashA:
	push af,de
	call bos.sys_FlashUnlock
	pop de,af
	call ti.WriteFlashA
	jp bos.sys_FlashLock

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
	jr z,.exit
	call _print
	xor a,a
	ld (curcol),a
	ld hl,currow
	inc (hl)
	pop hl
	inc hl
	inc hl
	inc hl
	jr .loop
.exit:
	pop bc
	call gfx_BlitBuffer
	jp bos.sys_WaitKeyCycle
readme_strings:
	dl ._1, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, ._10, $FF0000
._1: db "--MEMEDIT v1.0 by BeckATI--",0
._2: db "Arrow keys navigate the cursor.",0
._3: db "Clear quits. +/- scroll up/down.",0
._4: db "0-9,A-F write hex nibbles.",0
._5: db " two of these must be pressed",0
._6: db " in order to write a byte",0
._7: db "This program will only edit RAM.",0
._8: db "Because editing flash directly is",0
._9: db "usually a bad idea.",0
._10: db "Press any key to continue.",0

libload_load:
	ld hl,.libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jr c,.notfound
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
	db "/lib/LibLoad.LLL",0

.notfound:
	xor   a,a
	inc   a
	ret

libload_relocations:
db	$C0, "GRAPHX", $00, 11
gfx_Begin:
	jp 0
gfx_SetColor:
	jp 6
gfx_SetDraw:
	jp 27
gfx_Blit:
	jp 33
gfx_PrintStringXY:
	jp 54
gfx_SetTextBGColor:
	jp 60
gfx_SetTextFGColor:
	jp 63
gfx_SetTextTransparentColor:
	jp 66
gfx_HorizLine:
	jp 93
gfx_ZeroScreen:
	jp 228

	xor a,a
	pop hl
	ret

gfx_BlitBuffer:
	ld c,1
	push bc
	call gfx_Blit
	pop bc
	ret

string_file_too_large:
	db "File too large to open safely!",0

