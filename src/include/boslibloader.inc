
LIBLOAD_DEFAULT     :=  0
LIBLOAD_SILENT      :=  $AA55AA
LIBLOAD_USEMALLOC   :=  $AA5AA5

macro libload?.load? whence:LIBLOAD_DEFAULT
	virtual
		__libload_relocation_data::
	end virtual

	call __libload_load
	postpone
		__libload_load:
			ld hl,__libload_name
			push hl
			call bos.sys_OpenFileInLib
			pop bc
			jr c,__libload_fail
			ld bc,__libload_fail
			push bc
			if whence > 0
				ld bc,whence
			end if
			ld de,__libload_relocations
			jp (hl)
		__libload_fail:
			xor a,a
			inc a
			ret
		__libload_name:
			db "/lib/LibLoad.dll",0
		__libload_relocations:
			virtual __libload_relocation_data
				load __libload_relocation_data.data: $-$$ from $$
			end virtual
			db __libload_relocation_data.data
			pop hl
			xor a,a
			ret
	end postpone
end macro

macro libload? libname
	virtual __libload_relocation_data
		db libname.name
		if lengthof libname.name < 8
			db 0
		end if
		db libname.ver
	end virtual
end macro

macro library? libid, libname, libver
	__functionoffset = 0
	virtual
		db libname
		load `libname.name: $-$$ from $$
	end virtual
	libname.ver = libver
end macro

macro export? function
	if used function
		virtual __libload_relocation_data
			function:
				jp __functionoffset
				__functionoffset = __functionoffset + 3
		end virtual
	end if
end macro

library	srldrvce, "SRLDRVCE", 0
	export	srl_Open ; 0
	export	srl_Close ; 3
	export	srl_Read ; 6
	export	srl_Write ; 9
	export	srl_GetCDCStandardDescriptors ; 12
	export	get_device_type_ ; 15
	export	get_endpoint_addresses_ ; 18
	export	ring_buf_contig_avail_ ; 21
	export	ring_buf_has_consecutive_region_ ; 24
	export	ring_buf_push_ ; 27
	export	ring_buf_pop_ ; 30
	export	ring_buf_update_read_ ; 33
	export	ring_buf_update_write_ ; 36

library	msddrvce, "MSDDRVCE", 1
	export	msd_Open ; 0
	export	msd_Close ; 3
	export	msd_Reset ; 6
	export	msd_Info ; 9
	export	msd_Read ; 12
	export	msd_Write ; 15
	export	msd_ReadAsync ; 18
	export	msd_WriteAsync ; 21
	export	msd_FindPartitions ; 24

library	keypadc, "KEYPADC", 2
	export	kb_Scan ; 0
	export	kb_ScanGroup ; 3
	export	kb_AnyKey ; 6
	export	kb_Reset ; 9

library	graphx, "GRAPHX", 11
	export	gfx_Begin ; 0
	export	gfx_End ; 3
	export	gfx_SetColor ; 6
	export	gfx_SetDefaultPalette ; 9
	export	gfx_SetPalette ; 12
	export	gfx_FillScreen ; 15
	export	gfx_SetPixel ; 18
	export	gfx_GetPixel ; 21
	export	gfx_GetDraw ; 24
	export	gfx_SetDraw ; 27
	export	gfx_SwapDraw ; 30
	export	gfx_Blit ; 33
	export	gfx_BlitLines ; 36
	export	gfx_BlitRectangle ; 39
	export	gfx_PrintChar ; 42
	export	gfx_PrintInt ; 45
	export	gfx_PrintUInt ; 48
	export	gfx_PrintString ; 51
	export	gfx_PrintStringXY ; 54
	export	gfx_SetTextXY ; 57
	export	gfx_SetTextBGColor ; 60
	export	gfx_SetTextFGColor ; 63
	export	gfx_SetTextTransparentColor ; 66
	export	gfx_SetFontData ; 69
	export	gfx_SetFontSpacing ; 72
	export	gfx_SetMonospaceFont ; 75
	export	gfx_GetStringWidth ; 78
	export	gfx_GetCharWidth ; 81
	export	gfx_GetTextX ; 84
	export	gfx_GetTextY ; 87
	export	gfx_Line ; 90
	export	gfx_HorizLine ; 93
	export	gfx_VertLine ; 96
	export	gfx_Circle ; 99
	export	gfx_FillCircle ; 102
	export	gfx_Rectangle ; 105
	export	gfx_FillRectangle ; 108
	export	gfx_Line_NoClip ; 111
	export	gfx_HorizLine_NoClip ; 114
	export	gfx_VertLine_NoClip ; 117
	export	gfx_FillCircle_NoClip ; 120
	export	gfx_Rectangle_NoClip ; 123
	export	gfx_FillRectangle_NoClip ; 126
	export	gfx_SetClipRegion ; 129
	export	gfx_GetClipRegion ; 132
	export	gfx_ShiftDown ; 135
	export	gfx_ShiftUp ; 138
	export	gfx_ShiftLeft ; 141
	export	gfx_ShiftRight ; 144
	export	gfx_Tilemap ; 147
	export	gfx_Tilemap_NoClip ; 150
	export	gfx_TransparentTilemap ; 153
	export	gfx_TransparentTilemap_NoClip ; 156
	export	gfx_TilePtr ; 159
	export	gfx_TilePtrMapped ; 162
	export	gfx_Reserved ; 165
	export	gfx_AllocSprite ; 168
	export	gfx_Sprite ; 171
	export	gfx_TransparentSprite ; 174
	export	gfx_Sprite_NoClip ; 177
	export	gfx_TransparentSprite_NoClip ; 180
	export	gfx_GetSprite ; 183
	export	gfx_ScaledSprite_NoClip ; 186
	export	gfx_ScaledTransparentSprite_NoClip ; 189
	export	gfx_FlipSpriteY ; 192
	export	gfx_FlipSpriteX ; 195
	export	gfx_RotateSpriteC ; 198
	export	gfx_RotateSpriteCC ; 201
	export	gfx_RotateSpriteHalf ; 204
	export	gfx_Polygon ; 207
	export	gfx_Polygon_NoClip ; 210
	export	gfx_FillTriangle ; 213
	export	gfx_FillTriangle_NoClip ; 216
	export	gfx_Deprecated ; 219
	export	gfx_SetTextScale ; 222
	export	gfx_SetTransparentColor ; 225
	export	gfx_ZeroScreen ; 228
	export	gfx_SetTextConfig ; 231
	export	gfx_GetSpriteChar ; 234
	export	gfx_Lighten ; 237
	export	gfx_Darken ; 240
	export	gfx_SetFontHeight ; 243
	export	gfx_ScaleSprite ; 246
	export	gfx_FloodFill ; 249
	export	gfx_RLETSprite ; 252
	export	gfx_RLETSprite_NoClip ; 255
	export	gfx_ConvertFromRLETSprite ; 258
	export	gfx_ConvertToRLETSprite ; 261
	export	gfx_ConvertToNewRLETSprite ; 264
	export	gfx_RotateScaleSprite ; 267
	export	gfx_RotatedScaledTransparentSprite_NoClip ; 270
	export	gfx_RotatedScaledSprite_NoClip ; 273
	export	gfx_SetCharData ; 276
	export	gfx_Wait ; 279
	export	gfx_CopyRectangle ; 282

library	fontlibc, "FONTLIBC", 2
	export	fontlib_SetWindow ; 0
	export	fontlib_SetWindowFullScreen ; 3
	export	fontlib_GetWindowXMin ; 6
	export	fontlib_GetWindowYMin ; 9
	export	fontlib_GetWindowWidth ; 12
	export	fontlib_GetWindowHeight ; 15
	export	fontlib_SetCursorPosition ; 18
	export	fontlib_GetCursorX ; 21
	export	fontlib_GetCursorY ; 24
	export	fontlib_ShiftCursorPosition ; 27
	export	fontlib_SetFont ; 30
	export	fontlib_SetForegroundColor ; 33
	export	fontlib_SetBackgroundColor ; 36
	export	fontlib_SetColors ; 39
	export	fontlib_GetForegroundColor ; 42
	export	fontlib_GetBackgroundColor ; 45
	export	fontlib_SetTransparency ; 48
	export	fontlib_GetTransparency ; 51
	export	fontlib_SetLineSpacing ; 54
	export	fontlib_GetSpaceAbove ; 57
	export	fontlib_GetSpaceBelow ; 60
	export	fontlib_SetItalicSpacingAdjustment ; 63
	export	fontlib_GetItalicSpacingAdjustment ; 66
	export	fontlib_GetCurrentFontHeight ; 69
	export	fontlib_ValidateCodePoint ; 72
	export	fontlib_GetTotalGlyphs ; 75
	export	fontlib_GetFirstGlyph ; 78
	export	fontlib_SetNewlineCode ; 81
	export	fontlib_GetNewlineCode ; 84
	export	fontlib_SetAlternateStopCode ; 87
	export	fontlib_GetAlternateStopCode ; 90
	export	fontlib_SetFirstPrintableCodePoint ; 93
	export	fontlib_GetFirstPrintableCodePoint ; 96
	export	fontlib_SetDrawIntCodePoints ; 99
	export	fontlib_GetDrawIntMinus ; 102
	export	fontlib_GetDrawIntZero ; 105
	export	fontlib_GetGlyphWidth ; 108
	export	fontlib_GetStringWidth ; 111
	export	fontlib_GetStringWidthL ; 114
	export	fontlib_GetLastCharacterRead ; 117
	export	fontlib_DrawGlyph ; 120
	export	fontlib_DrawString ; 123
	export	fontlib_DrawStringL ; 126
	export	fontlib_DrawInt ; 129
	export	fontlib_DrawUInt ; 132
	export	fontlib_ClearEOL ; 135
	export	fontlib_ClearWindow ; 138
	export	fontlib_Newline ; 141
	export	fontlib_SetNewlineOptions ; 144
	export	fontlib_GetNewlineOptions ; 147
	export	fontlib_GetFontPackName ; 150
	export	fontlib_GetFontByIndex ; 153
	export	fontlib_GetFontByIndexRaw ; 156
	export	fontlib_GetFontByStyle ; 159
	export	fontlib_GetFontByStyleRaw ; 162
	export	fontlib_ScrollWindowDown ; 165
	export	fontlib_ScrollWindowUp ; 168
	export	fontlib_Home ; 171
	export	fontlib_HomeUp ; 174

library	fileioc, "FILEIOC", 7
	export	ti_CloseAll ; 0
	export	ti_Open ; 3
	export	ti_OpenVar ; 6
	export	ti_Close ; 9
	export	ti_Write ; 12
	export	ti_Read ; 15
	export	ti_GetC ; 18
	export	ti_PutC ; 21
	export	ti_Delete ; 24
	export	ti_DeleteVar ; 27
	export	ti_Seek ; 30
	export	ti_Resize ; 33
	export	ti_IsArchived ; 36
	export	ti_SetArchiveStatus ; 39
	export	ti_Tell ; 42
	export	ti_Rewind ; 45
	export	ti_GetSize ; 48
	export	ti_GetTokenString ; 51
	export	ti_GetDataPtr ; 54
	export	ti_Detect ; 57
	export	ti_DetectVar ; 60
	export	ti_SetVar ; 63
	export	ti_StoVar ; 66
	export	ti_RclVar ; 69
	export	ti_AllocString ; 72
	export	ti_AllocList ; 75
	export	ti_AllocMatrix ; 78
	export	ti_AllocCplxList ; 81
	export	ti_AllocEqu ; 84
	export	ti_DetectAny ; 87
	export	ti_GetVATPtr ; 90
	export	ti_GetName ; 93
	export	ti_Rename ; 96
	export	ti_RenameVar ; 99
	export	ti_ArchiveHasRoom ; 102
	export	ti_SetGCBehavior ; 105

library	fatdrvce, "FATDRVCE", 1
	export	fat_Init ; 0
	export	fat_Deinit ; 3
	export	fat_DirList ; 6
	export	fat_GetVolumeLabel ; 9
	export	fat_Open ; 12
	export	fat_Close ; 15
	export	fat_SetSize ; 18
	export	fat_GetSize ; 21
	export	fat_SetAttrib ; 24
	export	fat_GetAttrib ; 27
	export	fat_SetPos ; 30
	export	fat_GetPos ; 33
	export	fat_Read ; 36
	export	fat_Write ; 39
	export	fat_Create ; 42
	export	fat_Delete ; 45

library	usbdrvce, "USBDRVCE", 0
	export	usb_Init ; 0
	export	usb_Cleanup ; 3
	export	usb_PollTransfers ; 6
	export	usb_HandleEvents ; 9
	export	usb_WaitForEvents ; 12
	export	usb_WaitForInterrupt ; 15
	export	usb_RefDevice ; 18
	export	usb_UnrefDevice ; 21
	export	usb_GetDeviceHub ; 24
	export	usb_SetDeviceData ; 27
	export	usb_GetDeviceData ; 30
	export	usb_GetDeviceFlags ; 33
	export	usb_FindDevice ; 36
	export	usb_ResetDevice ; 39
	export	usb_DisableDevice ; 42
	export	usb_GetDeviceAddress ; 45
	export	usb_GetDeviceSpeed ; 48
	export	usb_GetConfigurationDescriptorTotalLength ; 51
	export	usb_GetDescriptor ; 54
	export	usb_SetDescriptor ; 57
	export	usb_GetStringDescriptor ; 60
	export	usb_SetStringDescriptor ; 63
	export	usb_GetConfiguration ; 66
	export	usb_SetConfiguration ; 69
	export	usb_GetInterface ; 72
	export	usb_SetInterface ; 75
	export	usb_SetEndpointHalt ; 78
	export	usb_ClearEndpointHalt ; 81
	export	usb_GetDeviceEndpoint ; 84
	export	usb_GetEndpointDevice ; 87
	export	usb_SetEndpointData ; 90
	export	usb_GetEndpointData ; 93
	export	usb_GetEndpointAddress ; 96
	export	usb_GetEndpointTransferType ; 99
	export	usb_GetEndpointMaxPacketSize ; 102
	export	usb_GetEndpointInterval ; 105
	export	usb_SetEndpointFlags ; 108
	export	usb_GetEndpointFlags ; 111
	export	usb_GetRole ; 114
	export	usb_GetFrameNumber ; 117
	export	usb_ControlTransfer ; 120
	export	usb_Transfer ; 123
	export	usb_ScheduleControlTransfer ; 126
	export	usb_ScheduleTransfer ; 129
	export	usb_MsToCycles ; 132
	export	usb_GetCycleCounter ; 135
	export	usb_GetCycleCounterHigh ; 138
	export	usb_StopTimer ; 141
	export	usb_StartTimerCycles ; 144
	export	usb_RepeatTimerCycles ; 147

purge library, export
