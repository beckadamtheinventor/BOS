load_libload:
	ld hl,libload_name
	push hl
	call bos.fs_GetFilePtr
	pop bc
	jq c,.notfound
	ld   de,.relocations
	ld   bc,.notfound
	push   bc
	jp   (hl)

.notfound:
	xor   a,a
	inc   a
	ret

.relocations:
	db	$C0, "GRAPHX", $00, 11
gfx_SetColor:
	jp 6
gfx_FillScreen:
	jp 15
gfx_SetDraw:
	jp 27
gfx_Blit:
	jp 33
gfx_PrintChar:
	jp 42
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
gfx_SetFontData:
	jp 69
gfx_SetFontSpacing:
	jp 72
gfx_GetStringWidth:
	jp 78
gfx_HorizLine:
	jp 93
gfx_Rectangle:
	jp 105
gfx_FillRectangle:
	jp 108
gfx_TransparentSprite:
	jp 174
gfx_SetTextScale:
	jp 222
gfx_SetTransparentColor:
	jp 225
gfx_ScaleSprite:
	jp 246
gfx_SetCharData:
	jp 276

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

libload_name:
	db   "/lib/LibLoad.dll", 0
.len := $ - .

gfx_BlitBuffer:
	ld c,1
	push bc
	call gfx_Blit
	pop bc
	ret

