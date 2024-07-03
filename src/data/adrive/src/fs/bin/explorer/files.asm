
explorer_create_new_file:
	ld hl,new_file_option_strings
	jq explorer_taskbar_menu

explorer_create_new_file_file:
	ld hl,$FF0000
	ld de,str_NewFileNamePrompt
	call explorer_input_file_name
	ld bc,0
	push bc,bc,hl
	call bos.fs_CreateFile
	pop bc,bc,bc
explorer_create_new_file_link:
explorer_create_new_file_image:
	ret

explorer_create_new_file_dir:
	ld hl,$FF0000
	ld de,str_NewDirNamePrompt
	call explorer_input_file_name
	ld c,1 shl bos.fd_subdir
	push bc,hl
	call bos.fs_CreateDir
	pop bc,bc
	ret

explorer_is_path_root:
	ld hl,(explorer_dirname_buffer)
	add hl,de
	xor a,a
	sbc hl,de
	ret z ; dirname is null
	or a,(hl)
	ret z ; dirname is empty string
	inc hl
	sub a,'/'
	or a,(hl)
	ret

explorer_delete_file:
; try not to delete root by mistake
	call explorer_is_path_root
	ret z
	ld hl,str_ConfirmDelete
	ld bc,display_margin_bottom-9
	ld de,display_margin_left+11
	push bc,de,hl
	call gfx_PrintStringXY
	pop bc,bc,bc
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	cp a,ti.skEnter
	jq nz,explorer_main
	ld hl,(explorer_dirname_buffer)
	ld de,(current_working_dir)
	push hl,de
	call bos.fs_JoinPath
	ex (sp),hl
	call bos.fs_DeleteFile
	call bos.sys_Free ; free file path allocated by fs_JoinPath
	pop bc,bc
	jq explorer_dirlist

explorer_cut_file:
	db $3E
explorer_copy_file:
	xor a,a
	ld (explorer_cut_file_indicator),a
	ld hl,(explorer_dirname_buffer)
	push hl
	call ti._strlen
	inc hl
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c
	ld (bos.copy_buffer),de
	ldir
	ret

explorer_paste_file:
	ld hl,(bos.copy_buffer)
	add hl,bc
	xor a,a
	sbc hl,bc
	ret z
	or a,(hl)
	ret z

	push hl
	call bos.fs_BaseName
	ld de,str_DestinationFilePrompt
	call explorer_input_file_name
	push hl
	or a,a
	jr z,.cancel
	ld hl,(explorer_dirname_buffer)
	push hl
	call bos.fs_ParentDir
	ex (sp),hl
	call bos.fs_JoinPath ; join(dirname(dest), basename(src))
	ld (.destfile),hl
	call bos.sys_Free ; free memory allocated by parentdir
	pop bc
	call bos.sys_Free ; free memory allocated by basename
	pop bc,bc

	ld hl,0
.destfile:=$-3
	add hl,bc
	xor a,a
	sbc hl,bc
	ret z ; return if failed to get destination file name
	or a,0
explorer_cut_file_indicator:=$-1
	; or a,a
	jr z,.copy
	push hl,bc
	call bos.fs_MoveFile
	scf
	sbc hl,hl
	ld de,(bos.copy_buffer)
	ld (bos.copy_buffer),hl
	push de
	call bos.sys_Free
	pop bc
.cancel:
	pop bc,bc
	ret
.copy:
	push hl,bc
	call bos.fs_GetFilePtr ; returns bc=len, hl=ptr, a=attr
	pop de,de
	push bc,hl
	ld c,a
	push bc,de
	call bos.fs_WriteNewFile ; copy file in copy buffer to the current working directory
	pop bc,bc,bc,bc
	ret

explorer_input_file_name:
	push de
	push hl
	ld bc,256
	push bc
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	jr c,.malloc_failed
	ld (explorer_temp_name_input_buffer),de
	ldir
.malloc_failed:
	pop hl
	ret c
	ld bc,188
	push bc
	ld c,b
	push bc,hl
	call gfx_PrintStringXY
	pop bc,bc
	ld hl,256
	ex (sp),hl
	ld hl,(explorer_temp_name_input_buffer)
	push hl
	xor a,a
	ld (ti.curCol),a
	ld a,22
	ld (ti.curRow),a
.paste_wait_input:
	call bos.gui_InputNoClear
	cp a,2
	jq nc,.paste_wait_input
	pop hl,bc
	or a,1
	ret


explorer_info_menu:
	call explorer_is_path_root
	jq z,explorer_main.key_loop
	ld a,(explorer_statusbar_color)
	ld l,a
	push hl
	call gfx_SetColor
	ld hl,88 ;H
	ex (sp),hl
	ld hl,258 ;W
	push hl
	ld hl,64 ;Y
	push hl
	ld hl,31 ;X
	push hl
	call gfx_FillRectangle
	pop bc,bc,bc
	ld a,(explorer_foreground_color)
	ld l,a
	ex (sp),hl
	call gfx_SetColor
	ld hl,90 ;H
	ex (sp),hl
	ld hl,260 ;W
	push hl
	ld hl,63 ;Y
	push hl
	ld hl,30 ;X
	push hl
	call gfx_Rectangle
	pop bc,bc,bc
	ld hl,65 ;Y
	ex (sp),hl
	ld hl,32 ;X
	push hl
	call gfx_SetTextXY
	pop bc,bc
	ld hl,(explorer_dirname_buffer)
	push hl
	ld bc,32
	call explorer_display_bc_chars
	call bos.fs_GetFilePtr
	pop de

	push hl
	bit bos.fd_subdir,a
	push af,bc
	jr nz,.info.is_dir

	ld hl,76 ;Y
	push hl
	ld hl,36 ;X
	push hl
	ld hl,str_file_size
	push hl
	call gfx_PrintStringXY
	pop hl,hl
	ld l,' '
	ex (sp),hl
	call gfx_PrintChar
	pop bc
	call gfx_PrintUInt
	ld hl,str_bytes
	push hl
	call gfx_PrintString
	pop hl
.info.is_dir:
	ld hl,86 ;Y
	push hl
	ld hl,36 ;X
	push hl
	call gfx_SetTextXY
	pop hl,hl

	pop bc,af
	bit bos.fd_system,a
	call nz,.info.system
	bit bos.fd_device,a
	call nz,.info.device
	bit bos.fd_subdir,a
	call nz,.info.subdir
	
	bit bos.fd_subdir,a
	pop bc
	jr nz,.not_executable_probably
	push bc
	call bos.sys_GetExecTypeFD
	jr c,.not_executable_probably
	ld de,(hl)

	db $21, "FEX"
	or a,a
	sbc hl,de
	jr z,.info_fex

	db $21, "REX"
	or a,a
	sbc hl,de
	jr z,.info_rex

	db $21, "TFX"
	or a,a
	sbc hl,de
	jr z,.info_fex

	db $21, "TRX"
	or a,a
	sbc hl,de
	jr z,.info_rex

	jr .not_executable_probably

.info_fex:
	ld hl,str_FlashExecutable
	jr .display_file_type

.info_rex:
	ld hl,str_RamExecutable

.display_file_type:
	ld bc,96 ;Y
	push bc
	ld bc,36 ;X
	push bc
	push hl
	call gfx_PrintString
	pop bc,bc,bc

.not_executable_probably:
	call gfx_BlitBuffer
	call bos.sys_WaitKeyCycle
	jq explorer_dirlist

.info.subdir:
	ld hl,str_subdir
	jr .info.sysdevdir
.info.device:
	ld hl,str_device
	jr .info.sysdevdir
.info.system:
	ld hl,str_system
.info.sysdevdir:
	push af
	push hl
	call gfx_PrintString
	pop bc
	pop af
	ret
