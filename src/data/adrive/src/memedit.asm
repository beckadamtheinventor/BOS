
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jr mem_edit
	db "REX",0
mem_edit:
	call libload_load
	ret nz
	ld (SaveIX),ix
	ld (SaveSP),sp
mem_edit_main:
	ld bc,8
	push bc
	call bos.sys_Malloc
	pop bc
	push hl
	pop ix
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jr z,.dont_open_file
	push hl
	call bos.fs_OpenFile
	pop bc
	jr c,.dont_open_file
	ld bc,$1C
	push hl
	add hl,bc
	ld hl,(hl)
	ld bc,(bos.remaining_free_RAM)
	or a,a
	sbc hl,bc
	add hl,bc
	jr nc,.file_too_large
	ex hl,de
	pop hl
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
	jr .init_editor
.file_too_large:
	ld hl,string_file_too_large
	call _print
	pop hl
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
	ld c,1
	push bc
	call gfx_SetDraw
	pop bc
.main_loop:
	ld a,(ix-7)
	cp a,$FF
	jr nz,.main_draw
	and a,7
	ld (ix-7),a
	jq .backwardpage
.main_draw:
	call .clearscreen
	call .setdefaultcolors
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
	ld b,8
.inner:
	ld a,(hl)
	inc hl
	push hl,bc
	call _print8h
	pop bc,hl
	ld a,(curcol)
	inc a
	ld (curcol),a
	djnz .inner
	ld a,(currow)
	inc a
	ld (currow),a
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
	ld bc,9
	add hl,bc
	ld c,20
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
	cp a,12 ;"*"/"R" key
	jq z,.maybeerasesector
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
	jr c,.flashwrite
	ld (hl),a
	jp .main_loop
.exit:
	call gfx_ZeroScreen
	call gfx_BlitBuffer
	ld sp,0
SaveSP:=$-3
	ld ix,0
SaveIX:=$-3
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
.flashwrite:
	ex hl,de
	call ___WriteFlashA
	jp .main_loop
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
.maybeerasesector:
	call .clearscreen
	ld hl,string_erase_sector
	call _print
	ld hl,string_are_you_sure
	call _print
	ld hl,string_press_enter_confirm
	call _print
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	cp a,9
	call z,.erasesector
	jp .main_loop
.erasesector:
	or a,a
	sbc hl,hl
	ld bc,(ix-3)
	ld l,(ix-7)
	add hl,bc
	ld (bos.ScrapMem),hl
	ld a,(bos.ScrapMem+2)
	push af
	call bos.sys_FlashUnlock
	pop af
	call bos.sys_EraseFlashSector
	jp bos.sys_FlashLock
.clearscreen:
	call gfx_ZeroScreen
	xor a,a
	ld (currow),a
	ld (curcol),a
	ret
.setdefaultcolors:
	ld c,0
	push bc
	call gfx_SetTextTransparentColor
	call gfx_SetTextBGColor
	pop bc
	ld c,$FF
	push bc
	call gfx_SetTextFGColor
	call gfx_SetColor
	pop bc
	ret

.nibblekeys:
	db 33,34,26,18,35,27,19,36,28,20,47,39,31,46,38,30

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
	ld a,0
curcol:=$-1
	inc a
	ld (curcol),a
	dec a
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
.str:=$-3
	push hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	ret



libload_load:
	ld hl,.libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jr c,.notfound
	ld bc,0
	push bc,hl
	call bos.fs_GetClusterPtr
	pop bc,bc
	jr c,.notfound
	ld   de,libload_relocations
	ld   bc,.notfound
	push   bc
	ld   bc,$aa55aa
	jp   (hl)
.libload_name:
	db "A:/LibLoad.v21",0

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

string_erase_sector:
	db "Erase flash sector?",0
string_are_you_sure:
	db "Are you sure?",0
string_press_enter_confirm:
	db "Press [enter] to confirm",0
string_file_too_large:
	db "File too large to open safely!",0

