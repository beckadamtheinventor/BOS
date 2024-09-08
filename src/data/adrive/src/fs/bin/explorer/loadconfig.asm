explorer_load_config:
	ld hl,-6
	call ti._frameset
	ld hl,(ix+6)
	ld bc,(ix+9)
.loop:
	ld a,(hl)
	cp a,'#'
	jq z,.nextline
.check:
	push hl,bc
; push this so we can conditionally "return" to .next instead of using many conditional jumps.
; also so that we can call some of the subroutines (namely .setbackgroundimage) externally.
	ld bc,.next
	push bc
	ld bc,(hl)
	ld (ix-3),bc
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	inc hl
	cp a,'='
	ret nz ;fail if invalid statement
	ld a,(hl)
	inc hl
	cp a,'x'
	jq z,.hexbytearg
	cp a,'"'
	jq z,.stringargument
	ld d,'0'
	sub a,d
	ret c
	cp a,10
	ret nc
; decimal number argument
	ld e,a
; check next two digits are valid
	ld a,(hl)
	inc hl
	sub a,d
	cp a,10
	ret nc
	ld a,(hl)
	sub a,d
	cp a,10
	ret nc
	dec hl

	ld a,e
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	add a,(hl) ; add next character offset from '0'
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	add a,(hl) ; add next character offset from '0'
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	jq .setnumvalue
.stringargument:
	pop bc
	push bc
	ld (ix-6),hl
.readstringloop:
	cpir ;find end of string
	dec hl
	ld a,(hl)
	cp a,$5C
	jq nz,.foundendofstring
	inc hl
	inc hl
	ld a,'"'
	jq .readstringloop
.foundendofstring:
	ld de,(ix-6)
	or a,a
	sbc hl,de
	inc hl
	push de,hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c ;go to next line if failed to malloc
	dec bc
	ld (ix-6),de
	ldir
	xor a,a
	ld (de),a
	ld bc,(ix-3)
	db $21,"DIR"
str_dir:=$-3
	or a,a
	sbc hl,bc
	jq z,.setcurdir
	db $21,"IMG"
str_img:=$-3
	or a,a
	sbc hl,bc
	jq z,.setbackgroundimage
	db $21,"FNT"
str_fnt:=$-3
	or a,a
	sbc hl,bc
	ret nz
.setfont:
	ld hl,(ix-6)
	push hl
	call bos.fs_GetFilePtr
	pop de
	ret c
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	db $21,"FNT"
	or a,a
	sbc hl,bc
	ret nz
	push de
	call bos.gfx_SetFont
	ld hl,(bos.font_spacing)
	ex (sp),hl
	call gfx_SetFontSpacing
	ld hl,(bos.font_data)
	ex (sp),hl
	call gfx_SetFontData
	pop bc
	ret
.setcurdir:
	ld (current_working_dir),de
	ret
.hexbytearg:
	ld a,(hl)
	inc hl
	call .nibble
	inc a
	ret z ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,a
	add a,a
	add a,a
	add a,a
	ld e,a
	ld a,(hl)
	inc hl
	call .nibble
	inc a
	ret z ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,e
.setnumvalue:
	db $21, "BGC"
str_bgc:=$-3
	or a,a
	sbc hl,bc
	jq z,.setbgcolor
	db $21, "FGC"
str_fgc:=$-3
	or a,a
	sbc hl,bc
	jq z,.setfgcolor
	db $21, "SBC"
str_sbc:=$-3
	or a,a
	sbc hl,bc
	jq z,.setstatusbarcolor
	db $21, "FG2"
str_fg2:=$-3
	or a,a
	sbc hl,bc
	ret nz
.setfg2color:
	ld (explorer_foreground2_color),a
	ld (bos.lcd_text_fg2),a
	ret
.next:
	pop bc,hl
.nextline:
	ld a,$A
	cpir
	jp pe,.loop
.done:
	ld sp,ix
	pop ix
	ret

.setbgcolor:
	ld (explorer_background_color),a
	ld (bos.lcd_text_bg),a
	ld (bos.lcd_bg_color),a
	ret

.setfgcolor:
	ld (explorer_foreground_color),a
	ld (bos.lcd_text_fg),a
	ret

.setstatusbarcolor:
	ld (explorer_statusbar_color),a
	ret

.setbackgroundimage:
	ld hl,(ix-6)
.setbackgroundimage_entryhl:
	push hl
	call bos.fs_GetFilePtr
	pop de
	ret c
	ld bc,(hl)
	inc hl
	inc hl
	inc hl
	ex hl,de
	db $21,"IMG"
	or a,a
	sbc hl,bc
	jq z,.setbackgroundimg
	db $21,"SPT"
	sbc hl,bc
	ret nz ; return if unsupported image format
	ex hl,de
	ld a,(hl)
	inc hl
	or a,a
	jq z,.setimagesprite ; non-compressed image
; compressed image
	ld de,ti.vRam + ti.lcdHeight*ti.lcdWidth
	cp a,'0'
	jr z,.zx0_compressed
	cp a,'7'
	ret nz ; return if unsupported image format
; decompress into the back buffer so we can scale into safeRAM
	push de,hl,de
	call bos.util_Zx7Decompress
.pop3_setimagesprite:
	pop bc,bc,hl
	jr .setimagesprite
.zx0_compressed:
	push de,hl,de
	call bos.util_Zx0Decompress
	jr .pop3_setimagesprite
.setbackgroundimagespt:
	ex hl,de
.setimagesprite:
	ld b,(hl)
	inc hl
	ld a,(hl)
	dec hl
	ex hl,de
	ld hl,bos.safeRAM
	push hl,de
	ld (explorer_background_image_sprite),hl
	ld d,255
	ld e,b
	ld (hl),d
	inc hl
	ex hl,de
	mlt hl
	ld bc,0
	ld c,a
	call ti._idivu
	ex hl,de
	ld (hl),e
	call gfx_ScaleSprite
	pop bc,bc
	jr .set_background_file
.setbackgroundimg:
	ld a,(de)
	cp a,'0'
	jr z,.goodformat
	cp a,'7'
	ret nz ; dont load if the image is not compressed
.goodformat:
	ex hl,de
	ld de,bos.safeRAM
	ld (explorer_background_image_full),de
	ldi
	push hl,de
	cp a,'0'
	jr z,.dzx0
.dzx7:
	call bos.util_Zx7Decompress
	jr .donedecompressing
.dzx0:
	call bos.util_Zx0Decompress
.donedecompressing:
	pop bc,bc
.set_background_file:
	ld hl,(ix-6)
	ld (explorer_background_file),hl
	ret


.nibble:
	sub a,'0'
	jq c,.invalid
	cp a,10
	ret c
	sub a,7 ;subtract this from 'A'-'0' to get 10
	cp a,16 ;check if in range 'A'-'F'
	ret c ;return if in range
	sub a,$20 ;subtract 'a'-'A' to interpret lowercase
	cp a,16
	ret c ;return if within range 'a'-'f'
	ccf
.invalid:
	sbc a,a
	ret
